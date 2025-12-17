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
const form_data_1 = __importDefault(require("form-data"));
const types_1 = require("./types");
const WIRO_BASE_URL = 'https://api.wiro.ai/v1';
const TASK_DETAIL_ENDPOINT = `${WIRO_BASE_URL}/Task/Detail`;
const TASK_KILL_ENDPOINT = `${WIRO_BASE_URL}/Task/Kill`;
const TASK_CANCEL_ENDPOINT = `${WIRO_BASE_URL}/Task/Cancel`;
/**
 * Wiro API client with multipart support for image uploads
 */
class WiroClient {
    constructor(apiKey, apiSecret) {
        this.apiKey = apiKey;
        this.apiSecret = apiSecret;
    }
    /**
     * Generate authentication headers for Wiro API
     */
    generateAuthHeaders() {
        const nonce = Math.floor(Date.now() / 1000).toString();
        const signatureData = this.apiSecret + nonce;
        const signature = crypto
            .createHmac('sha256', this.apiKey)
            .update(signatureData)
            .digest('hex');
        return {
            'x-api-key': this.apiKey,
            'x-nonce': nonce,
            'x-signature': signature,
        };
    }
    /**
     * Convert base64 image to Buffer
     */
    base64ToBuffer(base64) {
        // Remove data URL prefix if present
        const base64Data = base64.replace(/^data:image\/\w+;base64,/, '');
        return Buffer.from(base64Data, 'base64');
    }
    /**
     * Run a task with multipart form-data (for image uploads)
     */
    async runTaskMultipart(modelType, formData) {
        const endpoint = types_1.WIRO_MODEL_ENDPOINTS[modelType];
        if (!endpoint) {
            throw new Error(`Unknown model type: ${modelType}`);
        }
        const authHeaders = this.generateAuthHeaders();
        const response = await (0, node_fetch_1.default)(endpoint, {
            method: 'POST',
            headers: Object.assign(Object.assign({}, authHeaders), formData.getHeaders()),
            body: formData,
        });
        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`Wiro API error: ${response.status} ${response.statusText} - ${errorText}`);
        }
        return (await response.json());
    }
    /**
     * Run a task with JSON body (for text-only requests)
     */
    async runTaskJson(modelType, body) {
        const endpoint = types_1.WIRO_MODEL_ENDPOINTS[modelType];
        if (!endpoint) {
            throw new Error(`Unknown model type: ${modelType}`);
        }
        const response = await (0, node_fetch_1.default)(endpoint, {
            method: 'POST',
            headers: Object.assign(Object.assign({}, this.generateAuthHeaders()), { 'Content-Type': 'application/json' }),
            body: JSON.stringify(body),
        });
        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`Wiro API error: ${response.status} ${response.statusText} - ${errorText}`);
        }
        return (await response.json());
    }
    /**
     * Run 3D Text Animations task (text only - uses JSON)
     */
    async runTextAnimations(caption, effectType, videoMode = 'std', callbackUrl) {
        return this.runTaskJson('wiro/3d-text-animations', Object.assign({ caption,
            effectType,
            videoMode }, (callbackUrl && { callbackUrl })));
    }
    /**
     * Run Product Ads task (image only - uses multipart)
     * @param inputImageBase64 Base64 encoded image
     */
    async runProductAds(inputImageBase64, effectType, videoMode = 'std', callbackUrl) {
        const formData = new form_data_1.default();
        formData.append('inputImage', this.base64ToBuffer(inputImageBase64), {
            filename: 'product.jpg',
            contentType: 'image/jpeg',
        });
        formData.append('effectType', effectType);
        formData.append('videoMode', videoMode);
        if (callbackUrl) {
            formData.append('callbackUrl', callbackUrl);
        }
        return this.runTaskMultipart('wiro/product-ads', formData);
    }
    /**
     * Run Product Ads with Caption task (image + text - uses multipart)
     */
    async runProductAdsWithCaption(inputImageBase64, caption, effectType, videoMode = 'std', callbackUrl) {
        const formData = new form_data_1.default();
        formData.append('inputImage', this.base64ToBuffer(inputImageBase64), {
            filename: 'product.jpg',
            contentType: 'image/jpeg',
        });
        formData.append('caption', caption);
        formData.append('effectType', effectType);
        formData.append('videoMode', videoMode);
        if (callbackUrl) {
            formData.append('callbackUrl', callbackUrl);
        }
        return this.runTaskMultipart('wiro/product-ads-with-caption', formData);
    }
    /**
     * Run Product Ads with Logo task (two images - uses multipart)
     */
    async runProductAdsWithLogo(productImageBase64, logoImageBase64, effectType, videoMode = 'std', callbackUrl) {
        const formData = new form_data_1.default();
        // Wiro expects inputImage array - we append both with same field name
        formData.append('inputImage', this.base64ToBuffer(productImageBase64), {
            filename: 'product.jpg',
            contentType: 'image/jpeg',
        });
        formData.append('inputImage', this.base64ToBuffer(logoImageBase64), {
            filename: 'logo.png',
            contentType: 'image/png',
        });
        formData.append('effectType', effectType);
        formData.append('videoMode', videoMode);
        if (callbackUrl) {
            formData.append('callbackUrl', callbackUrl);
        }
        return this.runTaskMultipart('wiro/product-ads-with-logo', formData);
    }
    /**
     * Get task detail by task ID
     */
    async getTaskDetailById(taskId) {
        const response = await (0, node_fetch_1.default)(TASK_DETAIL_ENDPOINT, {
            method: 'POST',
            headers: Object.assign(Object.assign({}, this.generateAuthHeaders()), { 'Content-Type': 'application/json' }),
            body: JSON.stringify({ taskid: taskId }),
        });
        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`Wiro API error: ${response.status} ${response.statusText} - ${errorText}`);
        }
        return (await response.json());
    }
    /**
     * Get task detail by socket token
     */
    async getTaskDetailByToken(token) {
        const response = await (0, node_fetch_1.default)(TASK_DETAIL_ENDPOINT, {
            method: 'POST',
            headers: Object.assign(Object.assign({}, this.generateAuthHeaders()), { 'Content-Type': 'application/json' }),
            body: JSON.stringify({ tasktoken: token }),
        });
        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`Wiro API error: ${response.status} ${response.statusText} - ${errorText}`);
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
            headers: Object.assign(Object.assign({}, this.generateAuthHeaders()), { 'Content-Type': 'application/json' }),
            body: JSON.stringify(body),
        });
        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`Wiro API error: ${response.status} ${response.statusText} - ${errorText}`);
        }
        return (await response.json());
    }
    /**
     * Cancel a queued task
     */
    async cancelTask(taskId) {
        const response = await (0, node_fetch_1.default)(TASK_CANCEL_ENDPOINT, {
            method: 'POST',
            headers: Object.assign(Object.assign({}, this.generateAuthHeaders()), { 'Content-Type': 'application/json' }),
            body: JSON.stringify({ taskid: taskId }),
        });
        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`Wiro API error: ${response.status} ${response.statusText} - ${errorText}`);
        }
        return (await response.json());
    }
}
exports.WiroClient = WiroClient;
//# sourceMappingURL=client.js.map