"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.WiroClient = void 0;
const crypto = __importStar(require("crypto"));
const node_fetch_1 = __importDefault(require("node-fetch"));
const WIRO_BASE_URL = 'https://api.wiro.ai/v1';
const RUN_ENDPOINT = `${WIRO_BASE_URL}/Run/wiro/product-ads`;
const TASK_DETAIL_ENDPOINT = `${WIRO_BASE_URL}/Task/Detail`;
const TASK_KILL_ENDPOINT = `${WIRO_BASE_URL}/Task/Kill`;
const TASK_CANCEL_ENDPOINT = `${WIRO_BASE_URL}/Task/Cancel`;
/**
 * Wiro API client
 */
class WiroClient {
    constructor(apiKey, apiSecret) {
        this.apiKey = apiKey;
        this.apiSecret = apiSecret;
    }
    /**
     * Generate authentication headers for Wiro API
     */
    generateHeaders() {
        // Generate nonce (unix timestamp)
        const nonce = Math.floor(Date.now() / 1000).toString();
        // Generate HMAC-SHA256 signature
        const signatureData = this.apiSecret + nonce;
        const signature = crypto
            .createHmac('sha256', this.apiKey)
            .update(signatureData)
            .digest('hex');
        return {
            'Content-Type': 'application/json',
            'x-api-key': this.apiKey,
            'x-nonce': nonce,
            'x-signature': signature,
        };
    }
    /**
     * Run a new video generation task
     */
    async runTask(request) {
        const response = await (0, node_fetch_1.default)(RUN_ENDPOINT, {
            method: 'POST',
            headers: this.generateHeaders(),
            body: JSON.stringify(request),
        });
        if (!response.ok) {
            throw new Error(`Wiro API error: ${response.status} ${response.statusText}`);
        }
        return (await response.json());
    }
    /**
     * Get task detail by task ID
     */
    async getTaskDetailById(taskId) {
        const response = await (0, node_fetch_1.default)(TASK_DETAIL_ENDPOINT, {
            method: 'POST',
            headers: this.generateHeaders(),
            body: JSON.stringify({ taskid: taskId }),
        });
        if (!response.ok) {
            throw new Error(`Wiro API error: ${response.status} ${response.statusText}`);
        }
        return (await response.json());
    }
    /**
     * Get task detail by socket token
     */
    async getTaskDetailByToken(token) {
        const response = await (0, node_fetch_1.default)(TASK_DETAIL_ENDPOINT, {
            method: 'POST',
            headers: this.generateHeaders(),
            body: JSON.stringify({ tasktoken: token }),
        });
        if (!response.ok) {
            throw new Error(`Wiro API error: ${response.status} ${response.statusText}`);
        }
        return (await response.json());
    }
    /**
     * Kill a running task
     */
    async killTask(taskId, socketToken) {
        const body = taskId
            ? { taskid: taskId }
            : { socketaccesstoken: socketToken };
        const response = await (0, node_fetch_1.default)(TASK_KILL_ENDPOINT, {
            method: 'POST',
            headers: this.generateHeaders(),
            body: JSON.stringify(body),
        });
        if (!response.ok) {
            throw new Error(`Wiro API error: ${response.status} ${response.statusText}`);
        }
    }
    /**
     * Cancel a queued task
     */
    async cancelTask(taskId) {
        const response = await (0, node_fetch_1.default)(TASK_CANCEL_ENDPOINT, {
            method: 'POST',
            headers: this.generateHeaders(),
            body: JSON.stringify({ taskid: taskId }),
        });
        if (!response.ok) {
            throw new Error(`Wiro API error: ${response.status} ${response.statusText}`);
        }
    }
}
exports.WiroClient = WiroClient;
//# sourceMappingURL=client.js.map