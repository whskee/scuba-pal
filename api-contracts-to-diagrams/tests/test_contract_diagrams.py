from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace

from scubapal_contract_diagrams.actuator import normalize_actuator_mappings
from scubapal_contract_diagrams.cli import generate
from scubapal_contract_diagrams.java_scan import scan_java_project
from scubapal_contract_diagrams.openapi import normalize_openapi
from scubapal_contract_diagrams.security import classify_auth


class ContractDiagramTests(unittest.TestCase):
    def test_openapi_normalizes_request_response(self) -> None:
        document = {
            "openapi": "3.0.1",
            "info": {"title": "Example"},
            "paths": {
                "/api/posts": {
                    "post": {
                        "tags": ["Posts"],
                        "operationId": "createPost",
                        "requestBody": {
                            "content": {
                                "application/json": {
                                    "schema": {"$ref": "#/components/schemas/CreatePostRequest"}
                                }
                            }
                        },
                        "responses": {
                            "201": {
                                "description": "Created",
                                "content": {
                                    "application/json": {
                                        "schema": {"$ref": "#/components/schemas/FeedPostView"}
                                    }
                                },
                            }
                        },
                    }
                }
            },
            "components": {"schemas": {"CreatePostRequest": {}, "FeedPostView": {}}},
        }

        summary = normalize_openapi(document)

        self.assertEqual(summary["schemas"], ["CreatePostRequest", "FeedPostView"])
        self.assertEqual(summary["endpoints"][0]["method"], "POST")
        self.assertEqual(summary["endpoints"][0]["requestDto"], "CreatePostRequest")
        self.assertEqual(summary["endpoints"][0]["responseDto"], "FeedPostView")

    def test_actuator_mappings_parse_runtime_handler(self) -> None:
        mappings = {
            "contexts": {
                "application": {
                    "mappings": {
                        "dispatcherServlets": {
                            "dispatcherServlet": [
                                {
                                    "handler": "com.scubapal.social.post.PostController#getById(Long,Authentication)",
                                    "predicate": "{GET [/api/posts/{id}]}",
                                    "details": {
                                        "handlerMethod": {
                                            "className": "com.scubapal.social.post.PostController",
                                            "name": "getById",
                                        },
                                        "requestMappingConditions": {
                                            "methods": ["GET"],
                                            "patterns": ["/api/posts/{id}"],
                                        },
                                    },
                                }
                            ]
                        }
                    }
                }
            }
        }

        routes = normalize_actuator_mappings(mappings)

        self.assertEqual(len(routes), 1)
        self.assertEqual(routes[0]["controller"], "PostController")
        self.assertEqual(routes[0]["handler"], "getById")
        self.assertEqual(routes[0]["path"], "/api/posts/{id}")

    def test_security_classifier_matches_scubapal_rules(self) -> None:
        self.assertEqual(classify_auth("POST", "/api/auth/login")["auth"], "Public")
        self.assertEqual(classify_auth("GET", "/api/posts/{id}")["auth"], "Public")
        self.assertEqual(classify_auth("POST", "/api/posts/{id}/like")["auth"], "Authenticated")
        self.assertEqual(classify_auth("GET", "/api/admin/stats")["roles"], ["ADMIN"])

    def test_java_scan_finds_controller_routes_and_tables(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            base = root / "scubapal-app/src/main/java/com/scubapal/social/post"
            base.mkdir(parents=True)
            (base / "Post.java").write_text(
                'package com.scubapal.social.post;\n@Entity\n@Table(schema = "social", name = "posts")\nclass Post {}\n',
                encoding="utf-8",
            )
            (base / "PostRepository.java").write_text(
                "package com.scubapal.social.post;\ninterface PostRepository extends JpaRepository<Post, Long> {}\n",
                encoding="utf-8",
            )
            (base / "PostService.java").write_text(
                "package com.scubapal.social.post;\nclass PostService { private final PostRepository postRepository = null; }\n",
                encoding="utf-8",
            )
            (base / "PostController.java").write_text(
                "package com.scubapal.social.post;\n"
                '@RestController\n@RequestMapping("/api/posts")\n'
                "class PostController {\n"
                "  private final PostService postService = null;\n"
                '  // @PostMapping\n'
                "  // public String commentedOut() { return \"\"; }\n"
                '  @GetMapping("/{id}")\n'
                "  public String getById() { return \"\"; }\n"
                "}\n",
                encoding="utf-8",
            )

            summary = scan_java_project(root)

            self.assertEqual(summary["routes"][0]["path"], "/api/posts/{id}")
            self.assertEqual(len(summary["routes"]), 1)
            self.assertEqual(summary["tablesByController"]["PostController"], ["social.posts"])

    def test_generate_writes_deterministic_artifacts_from_files(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "scubapal-ios/OpenAPI").mkdir(parents=True)
            openapi_file = root / "scubapal-ios/OpenAPI/scubapal-openapi.json"
            openapi_file.write_text(
                json.dumps(
                    {
                        "openapi": "3.0.1",
                        "info": {"title": "ScubaPal API", "version": "v1"},
                        "paths": {
                            "/api/auth/login": {
                                "post": {
                                    "tags": ["Authentication"],
                                    "operationId": "login",
                                    "responses": {"200": {"description": "OK"}},
                                }
                            }
                        },
                        "components": {"schemas": {}},
                    }
                ),
                encoding="utf-8",
            )
            args = SimpleNamespace(
                repo_root=root,
                base_url="http://localhost:65535",
                openapi_url="/v3/api-docs",
                mappings_url="/actuator/mappings",
                openapi_file=None,
                mappings_file=None,
                output_dir=Path("docs/routes"),
                docs_dir=Path("docs/content/api/routes"),
                timeout=0.01,
                skip_fetch=True,
                require_live=False,
                api_only_diagram=False,
            )

            result = generate(args)

            self.assertIn("docs/routes/routes.json", result["files"])
            routes = json.loads((root / "docs/routes/routes.json").read_text(encoding="utf-8"))["routes"]
            self.assertEqual(routes[0]["routeKey"], "POST /api/auth/login")
            self.assertTrue((root / "docs/content/api/routes/route-map.md").exists())


if __name__ == "__main__":
    unittest.main()
