import { ethers } from 'ethers';
import { readFileSync } from 'fs';
import path from 'path';
import SessionStorage from './session-storage';

export default class SessionValidator {
  private sessionStorage: SessionStorage;
  private provider: ethers.Provider;
  private wallet: ethers.Wallet;
  private contract: ethers.Contract;

  constructor(
  ) {
    this.sessionStorage = SessionStorage.getInstance();
    this.provider = new ethers.JsonRpcProvider(process.env.JSON_RPC_URL!);
    this.wallet = new ethers.Wallet(process.env.SERVICE_KEY!, this.provider);

    const contractAbi = JSON.parse(readFileSync(path.resolve('./abi/TuringGame.json'), 'utf-8')).abi;
    this.contract = new ethers.Contract(
      process.env.CONTRACT_ADDRESS!,
      contractAbi,
      this.wallet
    );
  }

  async writeContract(methodName: string, ...args: any[]) {
    try {
      const gasEstimate = await this.contract[methodName].estimateGas(...args);
      
      const gasPrice = await this.provider.getFeeData();

      const tx = await this.contract[methodName](...args, {
        gasLimit: gasEstimate * BigInt(120) / BigInt(100),
        maxFeePerGas: gasPrice.maxFeePerGas,
        maxPriorityFeePerGas: gasPrice.maxPriorityFeePerGas,
      });
      console.error('====>>>> TX <<<<====');
      console.error(tx);
      const receipt = await tx.wait();
      console.error('====>>>> REC <<<<====');
      console.error(receipt);
      return receipt;
    } catch (error) {
      console.error(`Error writing to contract: ${error}`);
      throw error;
    }
  }

  async validateSession(sessionIdToValidate: string) {
    const session = await this.sessionStorage.getSession(sessionIdToValidate);
    const playerIds = session.getPlayerIds();
    const sessionId = BigInt(session.getSessionId());
    const player1Id = BigInt(playerIds[0]);
    const player2Id = BigInt(playerIds[1]);
    const gasEstimate = await this.contract['validateVotes'].estimateGas(sessionId, player1Id, player2Id, ethers.parseEther("0.00001"));
    const adminExcess = gasEstimate * BigInt(105) / BigInt(100);
    console.error(`sessionId=${sessionId} player1=${player1Id} player2=${player2Id} adminExcess=${adminExcess}`);
    const result = await this.writeContract("validateVotes", sessionId, player1Id, player2Id, adminExcess);
  }
}

