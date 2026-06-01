import React from "react";
import { DimensionValue, StyleSheet, Text, View } from "react-native";
import { missions } from "../data/balancing";
import { useGameStore } from "../store/gameStore";
import { colors } from "../theme";
import { MissionDefinition } from "../types";
import { shortMoney, totalBuildings } from "../utils/economy";
import { BuyButton, Card, Panel } from "./Panel";

function progressForMission(mission: MissionDefinition) {
  const state = useGameStore.getState();
  switch (mission.metric) {
    case "money":
      return state.stats.totalEarned;
    case "visitors":
      return state.stats.visitorsServed;
    case "snacks":
      return state.stats.snacksSold;
    case "service":
      return state.upgrades.serviceSpeed;
    case "buildings":
      return totalBuildings(state.buildings);
    default:
      return 0;
  }
}

export function MissionsMenu({ onClose }: { onClose: () => void }) {
  const claimed = useGameStore((state) => state.claimedMissions);
  const claimMission = useGameStore((state) => state.claimMission);
  useGameStore((state) => state.stats);
  useGameStore((state) => state.upgrades);
  useGameStore((state) => state.buildings);

  return (
    <Panel title="Missions" subtitle="Kleine Ziele, grosses Kino-Imperium." onClose={onClose}>
      {missions.map((mission) => {
        const progress = progressForMission(mission);
        const complete = progress >= mission.target;
        const isClaimed = claimed.includes(mission.id);
        const progressWidth = `${Math.min(100, (progress / mission.target) * 100)}%` as DimensionValue;
        return (
          <Card key={mission.id}>
            <View style={styles.titleRow}>
              <Text style={styles.title}>{mission.title}</Text>
              <Text style={[styles.badge, complete && styles.badgeDone]}>{isClaimed ? "Done" : complete ? "Ready" : "Open"}</Text>
            </View>
            <Text style={styles.description}>{mission.description}</Text>
            <View style={styles.progress}>
              <View style={[styles.progressFill, { width: progressWidth }]} />
            </View>
            <View style={styles.footer}>
              <Text style={styles.progressText}>
                {Math.floor(Math.min(progress, mission.target))}/{mission.target}
              </Text>
              <BuyButton
                label={isClaimed ? "Claimed" : `Claim ${shortMoney(mission.reward)}`}
                disabled={!complete || isClaimed}
                onPress={() => claimMission(mission.id)}
              />
            </View>
          </Card>
        );
      })}
    </Panel>
  );
}

const styles = StyleSheet.create({
  titleRow: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between"
  },
  title: {
    color: colors.text,
    fontSize: 16,
    fontWeight: "900"
  },
  badge: {
    overflow: "hidden",
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 999,
    backgroundColor: colors.panel3,
    color: colors.muted,
    fontSize: 11,
    fontWeight: "900"
  },
  badgeDone: {
    backgroundColor: colors.green,
    color: "#08110d"
  },
  description: {
    color: colors.muted,
    fontSize: 12,
    lineHeight: 17,
    marginTop: 5
  },
  progress: {
    height: 10,
    borderRadius: 10,
    overflow: "hidden",
    backgroundColor: "rgba(255,255,255,0.08)",
    marginTop: 12
  },
  progressFill: {
    height: 10,
    backgroundColor: colors.green,
    borderRadius: 10
  },
  footer: {
    marginTop: 12,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between"
  },
  progressText: {
    color: colors.dim,
    fontSize: 12,
    fontWeight: "800"
  }
});
