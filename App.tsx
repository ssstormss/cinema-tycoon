import React, { useEffect, useMemo, useState } from "react";
import { SafeAreaView, StatusBar, StyleSheet, View } from "react-native";
import { StatusBar as ExpoStatusBar } from "expo-status-bar";
import { BottomNav } from "./src/components/BottomNav";
import { BuildMenu } from "./src/components/BuildMenu";
import { GameHud } from "./src/components/GameHud";
import { IsoLobby } from "./src/components/IsoLobby";
import { MissionsMenu } from "./src/components/MissionsMenu";
import { OfflineRewardModal } from "./src/components/OfflineRewardModal";
import { SettingsMenu } from "./src/components/SettingsMenu";
import { StatsMenu } from "./src/components/StatsMenu";
import { UpgradesMenu } from "./src/components/UpgradesMenu";
import { colors } from "./src/theme";
import { useGameStore } from "./src/store/gameStore";
import type { PanelId } from "./src/types";

export default function App() {
  const [panel, setPanel] = useState<PanelId | null>(null);
  const tick = useGameStore((state) => state.tick);
  const hydrateClock = useGameStore((state) => state.hydrateClock);
  const offlineReward = useGameStore((state) => state.offlineReward);
  const clearOfflineReward = useGameStore((state) => state.clearOfflineReward);
  const hydrated = useGameStore.persist.hasHydrated();

  useEffect(() => {
    hydrateClock();
    let previous = Date.now();
    const id = setInterval(() => {
      const now = Date.now();
      tick((now - previous) / 1000);
      previous = now;
    }, 500);
    return () => clearInterval(id);
  }, [hydrateClock, tick]);

  const activePanel = useMemo(() => {
    switch (panel) {
      case "build":
        return <BuildMenu onClose={() => setPanel(null)} />;
      case "upgrades":
        return <UpgradesMenu onClose={() => setPanel(null)} />;
      case "missions":
        return <MissionsMenu onClose={() => setPanel(null)} />;
      case "stats":
        return <StatsMenu onClose={() => setPanel(null)} />;
      case "settings":
        return <SettingsMenu onClose={() => setPanel(null)} />;
      default:
        return null;
    }
  }, [panel]);

  return (
    <View style={styles.root}>
      <ExpoStatusBar style="light" />
      <StatusBar barStyle="light-content" />
      <SafeAreaView style={styles.safe}>
        <GameHud />
        <IsoLobby hydrated={hydrated} />
        <BottomNav activePanel={panel} onSelect={setPanel} />
      </SafeAreaView>
      {activePanel}
      <OfflineRewardModal
        amount={offlineReward}
        visible={offlineReward > 1}
        onClose={clearOfflineReward}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: colors.background
  },
  safe: {
    flex: 1,
    backgroundColor: colors.background
  }
});

