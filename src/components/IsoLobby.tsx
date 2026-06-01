import React, { useEffect, useMemo, useRef } from "react";
import { Animated, Dimensions, StyleSheet, Text, View } from "react-native";
import Svg, {
  Circle,
  Defs,
  G,
  LinearGradient,
  Path,
  Polygon,
  Rect,
  Stop,
  Text as SvgText
} from "react-native-svg";
import { useGameStore } from "../store/gameStore";
import { colors } from "../theme";
import type { EarningsPopup, Visitor, VisitorPhase } from "../types";
import { hallCapacity, shortMoney, snackServicePerSecond, ticketServicePerSecond, visitorRate } from "../utils/economy";

const { width } = Dimensions.get("window");
const stageWidth = Math.min(width, 430);
const stageHeight = 520;
const centerX = stageWidth / 2;
const centerY = 220;
const tileW = 56;
const tileH = 28;

function iso(x: number, y: number) {
  return {
    x: centerX + (x - y) * (tileW / 2),
    y: centerY + (x + y) * (tileH / 2)
  };
}

function tilePath(x: number, y: number, w = 1, h = 1) {
  const p1 = iso(x, y);
  const p2 = iso(x + w, y);
  const p3 = iso(x + w, y + h);
  const p4 = iso(x, y + h);
  return `${p1.x},${p1.y} ${p2.x},${p2.y} ${p3.x},${p3.y} ${p4.x},${p4.y}`;
}

function visitorPoint(visitor: Visitor) {
  const route: Record<VisitorPhase, { from: [number, number]; to: [number, number] }> = {
    entering: { from: [4.6, 9.9], to: [4.2 + visitor.lane * 0.18, 7.2] },
    ticketQueue: { from: [4.2 + visitor.lane * 0.16, 7.2], to: [2.2, 5.6] },
    buyingTicket: { from: [2.2, 5.6], to: [1.4, 4.6] },
    snackQueue: { from: [1.4, 4.6], to: [6.3, 5.6] },
    buyingSnack: { from: [6.3, 5.6], to: [7.4, 4.4] },
    watchingMovie: { from: [7.4, 4.4], to: [4.5, 2.1] },
    leaving: { from: [4.5, 2.1], to: [4.7, 10.4] }
  };
  const segment = route[visitor.phase];
  const t = Math.max(0, Math.min(1, visitor.progress));
  const x = segment.from[0] + (segment.to[0] - segment.from[0]) * t;
  const y = segment.from[1] + (segment.to[1] - segment.from[1]) * t;
  return iso(x, y);
}

interface IsoLobbyProps {
  hydrated: boolean;
}

export function IsoLobby({ hydrated }: IsoLobbyProps) {
  const pulse = useRef(new Animated.Value(0)).current;
  const visitors = useGameStore((state) => state.visitors);
  const upgrades = useGameStore((state) => state.upgrades);
  const buildings = useGameStore((state) => state.buildings);
  const staff = useGameStore((state) => state.staff);
  const ticketQueue = useGameStore((state) => state.ticketQueue);
  const snackQueue = useGameStore((state) => state.snackQueue);
  const occupiedSeats = useGameStore((state) => state.occupiedSeats);
  const earningsPopups = useGameStore((state) => state.earningsPopups);

  useEffect(() => {
    const loop = Animated.loop(
      Animated.sequence([
        Animated.timing(pulse, { toValue: 1, duration: 1400, useNativeDriver: true }),
        Animated.timing(pulse, { toValue: 0, duration: 1400, useNativeDriver: true })
      ])
    );
    loop.start();
    return () => loop.stop();
  }, [pulse]);

  const scale = pulse.interpolate({ inputRange: [0, 1], outputRange: [1, 1.035] });

  const metrics = useMemo(
    () => [
      { label: "Flow", value: `${(visitorRate(upgrades, buildings) * 60).toFixed(0)}/min` },
      { label: "Ticket", value: `${ticketServicePerSecond(upgrades, staff, buildings).toFixed(1)}/s` },
      { label: "Snack", value: `${snackServicePerSecond(upgrades, staff, buildings).toFixed(1)}/s` },
      { label: "Seats", value: `${occupiedSeats}/${hallCapacity(upgrades, buildings, staff)}` }
    ],
    [buildings, occupiedSeats, staff, upgrades]
  );

  if (!hydrated) {
    return (
      <View style={styles.loading}>
        <Text style={styles.loadingText}>Loading cinema...</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Animated.View style={[styles.sceneWrap, { transform: [{ scale }] }]}>
        <Svg width={stageWidth} height={stageHeight} viewBox={`0 0 ${stageWidth} ${stageHeight}`}>
          <Defs>
            <LinearGradient id="floor" x1="0" x2="1" y1="0" y2="1">
              <Stop offset="0" stopColor="#251238" />
              <Stop offset="0.55" stopColor="#141022" />
              <Stop offset="1" stopColor="#341142" />
            </LinearGradient>
            <LinearGradient id="neonPink" x1="0" x2="1">
              <Stop offset="0" stopColor="#ff4fd8" />
              <Stop offset="1" stopColor="#4cc9f0" />
            </LinearGradient>
            <LinearGradient id="gold" x1="0" x2="1">
              <Stop offset="0" stopColor="#ffd166" />
              <Stop offset="1" stopColor="#ff9f1c" />
            </LinearGradient>
          </Defs>

          <Rect x="0" y="0" width={stageWidth} height={stageHeight} fill="#090814" />
          <Circle cx={centerX - 120} cy="88" r="96" fill="#ff4fd8" opacity="0.08" />
          <Circle cx={centerX + 132} cy="112" r="120" fill="#4cc9f0" opacity="0.07" />

          <Polygon points={tilePath(-0.4, -0.1, 9.8, 10.8)} fill="url(#floor)" stroke="#ffffff22" strokeWidth="2" />
          {Array.from({ length: 10 }).map((_, x) =>
            Array.from({ length: 10 }).map((__, y) => (
              <Polygon
                key={`${x}-${y}`}
                points={tilePath(x, y)}
                fill={(x + y) % 2 === 0 ? "#1b1328" : "#211532"}
                opacity="0.62"
                stroke="#ffffff08"
                strokeWidth="1"
              />
            ))
          )}

          <BuildingBlock x={0.5} y={4.5} w={2.2} h={1.5} height={56} fill="#ff9f1c" label="TICKETS" />
          <BuildingBlock x={6.5} y={4.4} w={2.2} h={1.6} height={54} fill="#ef476f" label="POPCORN" />
          <BuildingBlock x={3.0} y={0.7} w={4.0} h={1.6} height={78} fill="#4361ee" label="SCREEN 1" />
          <BuildingBlock x={0.6} y={1.4} w={2.0} h={1.6} height={46} fill="#9b5de5" label="STAFF" />
          <BuildingBlock x={7.1} y={1.4} w={1.8} h={1.7} height={48} fill="#06d6a0" label="BUILD" />
          {Array.from({ length: Math.max(0, buildings.ticketBooth - 1) }).map((_, index) => (
            <MiniKiosk key={`ticket-${index}`} x={0.6 + index * 0.55} y={6.25} fill="#ffd166" />
          ))}
          {Array.from({ length: Math.max(0, buildings.popcornStand - 1) }).map((_, index) => (
            <MiniKiosk key={`popcorn-${index}`} x={7.3 + index * 0.45} y={6.2} fill="#ef476f" />
          ))}
          {buildings.drinkStand > 0 && <BuildingBlock x={8.2} y={3.5} w={1.0} h={1.0} height={36} fill="#4cc9f0" label="DRINK" />}
          {buildings.candyShop > 0 && <BuildingBlock x={6.9} y={6.6} w={1.5} h={1.0} height={42} fill="#ff4fd8" label="CANDY" />}
          {buildings.vipHall > 0 && <BuildingBlock x={1.1} y={0.45} w={1.3} h={1.0} height={58} fill="#ffd166" label="VIP" />}
          {buildings.premiumLounge > 0 && <BuildingBlock x={7.55} y={0.55} w={1.4} h={1.05} height={52} fill="#06d6a0" label="LOUNGE" />}

          <Path d={`M ${iso(4.6, 9.8).x} ${iso(4.6, 9.8).y} L ${iso(4.4, 6.4).x} ${iso(4.4, 6.4).y}`} stroke="#ffd166" strokeWidth="10" opacity="0.18" strokeLinecap="round" />
          <Path d={`M ${iso(4.6, 9.8).x} ${iso(4.6, 9.8).y} L ${iso(4.4, 6.4).x} ${iso(4.4, 6.4).y}`} stroke="#ffd166" strokeWidth="2" opacity="0.55" strokeDasharray="6 9" />

          {Array.from({ length: buildings.cinemaHall * 3 + upgrades.hallCapacity }).slice(0, 18).map((_, index) => {
            const row = Math.floor(index / 6);
            const col = index % 6;
            return <Seat key={index} x={2.55 + col * 0.55} y={2.8 + row * 0.48} occupied={index < occupiedSeats} />;
          })}

          {visitors.map((visitor) => {
            const p = visitorPoint(visitor);
            return (
              <G key={visitor.id}>
                <Circle cx={p.x + 3} cy={p.y + 13} r="8" fill="#00000055" />
                <Circle cx={p.x} cy={p.y} r="9" fill={visitor.color} stroke="#ffffffaa" strokeWidth="1.4" />
                <Circle cx={p.x + 3} cy={p.y - 3} r="2.2" fill="#ffffffcc" />
              </G>
            );
          })}
          {earningsPopups.map((popup) => (
            <CashPopup key={popup.id} popup={popup} />
          ))}
        </Svg>
      </Animated.View>

      <View style={styles.queuePanel}>
        <View style={styles.queueItem}>
          <Text style={styles.queueLabel}>Ticket Queue</Text>
          <Text style={styles.queueValue}>{ticketQueue}</Text>
        </View>
        <View style={styles.queueItem}>
          <Text style={styles.queueLabel}>Snack Queue</Text>
          <Text style={styles.queueValue}>{snackQueue}</Text>
        </View>
      </View>

      <View style={styles.metrics}>
        {metrics.map((metric) => (
          <View style={styles.metric} key={metric.label}>
            <Text style={styles.metricLabel}>{metric.label}</Text>
            <Text style={styles.metricValue}>{metric.value}</Text>
          </View>
        ))}
      </View>
    </View>
  );
}

function CashPopup({ popup }: { popup: EarningsPopup }) {
  return (
    <G opacity="0.92">
      <Rect
        x={stageWidth * popup.x - 35}
        y={stageHeight * popup.y - 42}
        width="70"
        height="26"
        rx="13"
        fill="#06140f"
        stroke="#06d6a0"
        strokeWidth="1.4"
      />
      <SvgText
        x={stageWidth * popup.x}
        y={stageHeight * popup.y - 24}
        fill="#06d6a0"
        fontSize="12"
        fontWeight="900"
        textAnchor="middle"
      >
        +{shortMoney(popup.amount)}
      </SvgText>
    </G>
  );
}

function MiniKiosk({ x, y, fill }: { x: number; y: number; fill: string }) {
  const p = iso(x, y);
  return (
    <G>
      <Circle cx={p.x} cy={p.y + 18} r="14" fill="#00000044" />
      <Rect x={p.x - 15} y={p.y - 26} width="30" height="34" rx="7" fill={fill} opacity="0.92" />
      <Rect x={p.x - 10} y={p.y - 20} width="20" height="10" rx="3" fill="#fff7df" opacity="0.9" />
    </G>
  );
}

function BuildingBlock({ x, y, w, h, height, fill, label }: { x: number; y: number; w: number; h: number; height: number; fill: string; label: string }) {
  const top = tilePath(x, y, w, h);
  const p1 = iso(x, y + h);
  const p2 = iso(x + w, y + h);
  const p3 = { x: p2.x, y: p2.y + height };
  const p4 = { x: p1.x, y: p1.y + height };
  const front = `${p1.x},${p1.y} ${p2.x},${p2.y} ${p3.x},${p3.y} ${p4.x},${p4.y}`;
  const labelPoint = iso(x + w / 2, y + h / 2);
  return (
    <G>
      <Polygon points={front} fill="#0b0913" opacity="0.55" />
      <Polygon points={top} fill={fill} stroke="#ffffff44" strokeWidth="2" />
      <Polygon points={front} fill={fill} opacity="0.38" />
      <SvgText x={labelPoint.x} y={labelPoint.y + 5} fill="#fff7df" fontSize="11" fontWeight="900" textAnchor="middle">
        {label}
      </SvgText>
    </G>
  );
}

function Seat({ x, y, occupied }: { x: number; y: number; occupied: boolean }) {
  return (
    <Polygon
      points={tilePath(x, y, 0.42, 0.34)}
      fill={occupied ? "#ffd166" : "#ef476f"}
      opacity={occupied ? 0.95 : 0.55}
      stroke="#ffffff22"
      strokeWidth="1"
    />
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    overflow: "hidden"
  },
  sceneWrap: {
    width: stageWidth,
    height: stageHeight,
    shadowColor: colors.pink,
    shadowOpacity: 0.25,
    shadowRadius: 24,
    shadowOffset: { width: 0, height: 12 }
  },
  loading: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center"
  },
  loadingText: {
    color: colors.muted,
    fontWeight: "800"
  },
  queuePanel: {
    position: "absolute",
    top: 18,
    left: 16,
    gap: 8
  },
  queueItem: {
    paddingHorizontal: 12,
    paddingVertical: 9,
    borderRadius: 14,
    backgroundColor: "rgba(22,17,36,0.88)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.08)"
  },
  queueLabel: {
    color: colors.dim,
    fontSize: 10,
    fontWeight: "800"
  },
  queueValue: {
    color: colors.gold,
    fontSize: 18,
    fontWeight: "900"
  },
  metrics: {
    position: "absolute",
    right: 12,
    bottom: 16,
    width: 126,
    gap: 7
  },
  metric: {
    paddingHorizontal: 10,
    paddingVertical: 8,
    borderRadius: 13,
    backgroundColor: "rgba(33,23,47,0.88)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.08)"
  },
  metricLabel: {
    color: colors.dim,
    fontSize: 10,
    fontWeight: "800"
  },
  metricValue: {
    color: colors.cyan,
    fontSize: 13,
    fontWeight: "900"
  }
});
