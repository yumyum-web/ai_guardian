import * as admin from "firebase-admin";
import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions/v2";

admin.initializeApp();

export const sendSosAlert = onDocumentWritten(
    "sos/{valoraUid}",
    async (event) => {
        const afterData = event.data?.after?.data();
        const beforeData = event.data?.before?.data();

        // Only proceed if SOS is newly activated
        if (!afterData || afterData.active !== true || (beforeData && beforeData.active === true)) {
            logger.debug("SOS alert not sent: either not active or already active");
            return null;
        }

        const valoraUid = event.params.valoraUid;
        const valoraDoc = await admin.firestore().doc(`users/${valoraUid}`).get();
        if (!valoraDoc.exists) {
            logger.error(`Valora user ${valoraUid} not found`);
            return null;
        }

        const valoraName = valoraDoc.get("name") ?? "Valora";
        const guardians: string[] = valoraDoc.get("guardians") ?? [];
        if (guardians.length === 0) {
            logger.info(`No guardians found for user ${valoraUid}`);
            return null;
        }

        // Fetch all guardian tokens in parallel
        const tokenPromises = guardians.map(async (guardianUid) => {
            const guardianDoc = await admin.firestore().doc(`users/${guardianUid}`).get();
            return guardianDoc.exists ? guardianDoc.get("fcmToken") : null;
        });
        const tokens = (await Promise.all(tokenPromises)).filter((token): token is string => !!token);
        if (tokens.length === 0) {
            logger.info(`No FCM tokens found for guardians of user ${valoraUid}`);
            return null;
        }

        await admin.messaging().sendEachForMulticast({
            tokens,
            notification: {
                title: "🚨 SOS Alert",
                body: `${valoraName} is in SOS mode!`,
            },
            data: {
                type: "sos_alert",
                valoraUid,
            },
        });

        logger.log(`Sent SOS alert to ${tokens.length} guardians for user ${valoraUid}`);

        return null;
    }
);
