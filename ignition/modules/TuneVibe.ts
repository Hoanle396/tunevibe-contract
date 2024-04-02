import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const TuneVibeModule = buildModule("TuneVibeModule", (m) => {

  const TuneVibe = m.contract("TuneVibe",["0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199"]);

  return { TuneVibe };
});
export default TuneVibeModule;
