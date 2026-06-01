import { DiveLocationsApi, DiveShopsApi } from "@/api/generated";
import { api, apiConfig, pageParams, unwrap } from "@/services/api";
import { DiveLocation, DiveShop, User, toDiveLocation, toDiveShop } from "@/types/models";
import { usersApi } from "./usersApi";

const generatedLocationsApi = new DiveLocationsApi(apiConfig, undefined, api);
const generatedShopsApi = new DiveShopsApi(apiConfig, undefined, api);

export type SearchFilter = "profiles" | "shops" | "locations";

function normalize(value?: string | number | null): string {
  return String(value ?? "").trim().toLowerCase();
}

function matchesLocation(location: DiveLocation, term: string): boolean {
  if (!term) return true;
  const fields = [
    location.name,
    location.description,
    location.city,
    location.state,
    location.country,
    location.difficultyLevel
  ];
  return fields.some((field) => normalize(field).includes(term));
}

export const searchApi = {
  async profiles(term: string): Promise<User[]> {
    return usersApi.search(term);
  },

  async locations(term: string): Promise<DiveLocation[]> {
    const cleanTerm = term.trim();
    const params = pageParams(0, 100);
    const responses = await Promise.all([
      unwrap(generatedLocationsApi.getAll(cleanTerm || undefined, params.page, params.size)),
      cleanTerm ? unwrap(generatedLocationsApi.getAll(undefined, params.page, params.size)) : Promise.resolve(undefined)
    ]);
    const unique = new Map<string, DiveLocation>();

    responses
      .flatMap((response) => response?.content ?? [])
      .map(toDiveLocation)
      .filter((location) => matchesLocation(location, normalize(cleanTerm)))
      .forEach((location) => unique.set(String(location.id), location));

    return Array.from(unique.values()).slice(0, 50);
  },

  async shops(term: string): Promise<DiveShop[]> {
    const cleanTerm = term.trim();
    const params = pageParams(0, 100);
    const response = await unwrap(generatedShopsApi.getAll2(cleanTerm || undefined, params.page, params.size));
    return (response.content ?? []).map(toDiveShop);
  }
};
