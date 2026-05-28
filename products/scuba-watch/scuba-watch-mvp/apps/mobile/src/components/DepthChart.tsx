import type { DiveSample } from "@scuba-watch/dive-core";
import { StyleSheet, Text, View } from "react-native";
import Svg, { Line, Path, Rect, Text as SvgText } from "react-native-svg";
import { theme } from "../theme/theme";

interface DepthChartProps {
  samples: DiveSample[];
  maxDepthMeters: number;
}

export function DepthChart({ samples, maxDepthMeters }: DepthChartProps) {
  const width = 320;
  const height = 128;
  const padding = 14;
  const chartMaxDepth = Math.max(6, Math.ceil(maxDepthMeters + 2));

  const points = samples.map((sample, index) => {
    const x =
      padding +
      (samples.length <= 1
        ? 0
        : (index / (samples.length - 1)) * (width - padding * 2));
    const y =
      padding +
      (sample.depthMeters / chartMaxDepth) * (height - padding * 2);
    return `${x.toFixed(1)},${y.toFixed(1)}`;
  });

  const path = points.length > 0 ? `M ${points.join(" L ")}` : "";

  return (
    <View style={styles.container}>
      <Text style={styles.label}>Depth profile</Text>
      <Svg width="100%" height={height} viewBox={`0 0 ${width} ${height}`}>
        <Rect x="0" y="0" width={width} height={height} rx="8" fill={theme.colors.panel} />
        <Line
          x1={padding}
          x2={width - padding}
          y1={padding}
          y2={padding}
          stroke={theme.colors.border}
          strokeWidth="1"
        />
        <Line
          x1={padding}
          x2={width - padding}
          y1={height - padding}
          y2={height - padding}
          stroke={theme.colors.border}
          strokeWidth="1"
        />
        <SvgText x={padding} y={24} fill={theme.colors.muted} fontSize="10">
          0 m
        </SvgText>
        <SvgText x={padding} y={height - 18} fill={theme.colors.muted} fontSize="10">
          {chartMaxDepth} m
        </SvgText>
        {path ? (
          <Path
            d={path}
            fill="none"
            stroke={theme.colors.cyan}
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth="3"
          />
        ) : null}
      </Svg>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    gap: theme.spacing.sm
  },
  label: {
    color: theme.colors.muted,
    fontSize: 12,
    fontWeight: "700",
    letterSpacing: 0,
    textTransform: "uppercase"
  }
});
