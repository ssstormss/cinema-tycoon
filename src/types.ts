export type PanelId = "build" | "upgrades" | "missions" | "stats" | "settings";

export type UpgradeId =
  | "ticketPrice"
  | "serviceSpeed"
  | "visitorFlow"
  | "snackProfit"
  | "hallCapacity";

export type BuildingId =
  | "ticketBooth"
  | "popcornStand"
  | "cinemaHall"
  | "drinkStand"
  | "candyShop"
  | "vipHall"
  | "premiumLounge";

export type StaffId = "cashier" | "popcornPro" | "usher" | "manager";

export type MissionId =
  | "earnFirstCash"
  | "serveVisitors"
  | "sellSnacks"
  | "upgradeService"
  | "expandCinema"
  | "reachWealth";

export type VisitorPhase =
  | "entering"
  | "ticketQueue"
  | "buyingTicket"
  | "snackQueue"
  | "buyingSnack"
  | "watchingMovie"
  | "leaving";

export interface Visitor {
  id: string;
  lane: number;
  phase: VisitorPhase;
  progress: number;
  wantsSnack: boolean;
  color: string;
}

export interface EarningsPopup {
  id: string;
  amount: number;
  x: number;
  y: number;
  createdAt: number;
}

export interface UpgradeDefinition {
  id: UpgradeId;
  title: string;
  description: string;
  icon: string;
  baseCost: number;
  growth: number;
  maxLevel: number;
}

export interface BuildingDefinition {
  id: BuildingId;
  title: string;
  description: string;
  icon: string;
  baseCost: number;
  growth: number;
  maxCount: number;
}

export interface StaffDefinition {
  id: StaffId;
  title: string;
  description: string;
  icon: string;
  baseCost: number;
  growth: number;
  maxCount: number;
}

export interface MissionDefinition {
  id: MissionId;
  title: string;
  description: string;
  target: number;
  reward: number;
  metric: "money" | "visitors" | "snacks" | "service" | "buildings";
}

export interface GameStats {
  totalEarned: number;
  visitorsServed: number;
  snacksSold: number;
  ticketsSold: number;
  playSeconds: number;
}
