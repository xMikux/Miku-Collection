const NotificationProvider = require("./notification-provider");
const axios = require("axios");
const { DOWN, UP } = require("../../src/util");

class Discord extends NotificationProvider {

    name = "discord";

    async send(notification, msg, monitorJSON = null, heartbeatJSON = null) {
        let okMsg = "Sent Successfully.";

        try {
            const discordDisplayName = notification.discordUsername || "Uptime Kuma";

            // If heartbeatJSON is null, assume we're testing.
            if (heartbeatJSON == null) {
                let discordtestdata = {
                    username: discordDisplayName,
                    content: msg,
                };
                await axios.post(notification.discordWebhookUrl, discordtestdata);
                return okMsg;
            }

            let address;

            switch (monitorJSON["type"]) {
                case "ping":
                    address = monitorJSON["hostname"];
                    break;
                case "port":
                case "dns":
                case "steam":
                    address = monitorJSON["hostname"];
                    if (monitorJSON["port"]) {
                        address += ":" + monitorJSON["port"];
                    }
                    break;
                default:
                    address = monitorJSON["url"];
                    break;
            }

            // If heartbeatJSON is not null, we go into the normal alerting loop.
            if (heartbeatJSON["status"] === DOWN) {
                let discorddowndata = {
                    username: discordDisplayName,
                    embeds: [{
                        title: "❌ " + monitorJSON["name"] + " 服務出現故障 ❌",
                        color: 16711680,
                        timestamp: heartbeatJSON["time"],
                        fields: [
                            {
                                name: "服務名稱",
                                value: monitorJSON["name"],
                            },
                            // {
                            //     name: monitorJSON["type"] === "push" ? "Service Type" : "Service URL",
                            //     value: monitorJSON["type"] === "push" ? "Heartbeat" : address,
                            // },
                            {
                                name: "時間（UTC）",
                                value: heartbeatJSON["time"],
                            },
                            {
                                name: "錯誤資訊",
                                value: heartbeatJSON["msg"],
                            },
                        ],
                    }],
                };

                if (notification.discordPrefixMessage) {
                    discorddowndata.content = notification.discordPrefixMessage;
                }

                await axios.post(notification.discordWebhookUrl, discorddowndata);
                return okMsg;

            } else if (heartbeatJSON["status"] === UP) {
                let discordupdata = {
                    username: discordDisplayName,
                    embeds: [{
                        title: "✅ " + monitorJSON["name"] + " 服務已恢復 ✅",
                        color: 65280,
                        timestamp: heartbeatJSON["time"],
                        fields: [
                            {
                                name: "服務名稱",
                                value: monitorJSON["name"],
                            },
                            // {
                            //     name: monitorJSON["type"] === "push" ? "Service Type" : "Service URL",
                            //     value: monitorJSON["type"] === "push" ? "Heartbeat" : address.startsWith("http") ? "[Visit Service](" + address + ")" : address,
                            // },
                            {
                                name: "時間（UTC）",
                                value: heartbeatJSON["time"],
                            },
                            {
                                name: "延遲",
                                value: heartbeatJSON["ping"] == null ? "N/A" : heartbeatJSON["ping"] + " ms",
                            },
                        ],
                    }],
                };

                if (notification.discordPrefixMessage) {
                    discordupdata.content = notification.discordPrefixMessage;
                }

                await axios.post(notification.discordWebhookUrl, discordupdata);
                return okMsg;
            }
        } catch (error) {
            this.throwGeneralAxiosError(error);
        }
    }

}

module.exports = Discord;