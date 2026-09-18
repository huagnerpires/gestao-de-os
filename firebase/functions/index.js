const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const OneSignal = require("@onesignal/node-onesignal");

const kUserKey = "MWQ5NGEyNmMtNjRkOS00ZWM0LWFlNjMtM2Y3NTAyNmM1YjM4";
const kAPIKey = "ZTdlNjIwZWItMjEyMC00M2RhLWJlZmYtMzc2NTBmNzNmMDdj";

const kOneSignalUsageHeader = "FlutterFlow | Partner Integration";

const configuration = OneSignal.createConfiguration({
  userKey: kUserKey,
  appKey: kAPIKey,
  defaultHeaders: {
    "OneSignal-Usage": kOneSignalUsageHeader,
  },
});
const client = new OneSignal.DefaultApi(configuration);
const user = new OneSignal.User();
const axios = require("axios");

exports.addUser = functions.https.onCall(async (data, context) => {
  if (context.auth.uid != data.user_id) {
    return "Unauthenticated calls are not allowed.";
  }
  try {
    user.identity = {
      external_id: data.user_id,
    };
    user.properties = {
      tags: data.tags,
    };
    user.subscriptions = data.subscriptions;
    const createdUser = await client.createUser(
      "7b01186f-cf76-4b5d-8354-87d83737d40c",
      user,
    );
    if (createdUser.identity["onesignal_id"] == null) {
      throw new functions.https.HttpsError(
        "aborted",
        "Could not create OneSignal user",
      );
    }
    return createdUser;
  } catch (err) {
    console.error(
      `Unable to create user ${context.auth.uid}.
            Error ${err}`,
    );
    throw new functions.https.HttpsError(
      "aborted",
      "Could not create OneSignal user",
    );
  }
});

exports.deleteUser = functions.https.onCall(async (data, context) => {
  if (context.auth.uid != data.user_id) {
    return "Unauthenticated calls are not allowed.";
  }

  const url = `https://api.onesignal.com/apps/7b01186f-cf76-4b5d-8354-87d83737d40c/users/by/external_id/${data.user_id}`;

  try {
    await axios.delete(url, {
      headers: {
        Authorization: `Basic ${kAPIKey}`,
        "OneSignal-Usage": kOneSignalUsageHeader,
      },
    });
    return "User deleted";
  } catch (err) {
    console.error(
      `Unable to delete user ${context.auth.uid}. Error: ${err.message}`,
    );
    throw new functions.https.HttpsError(
      "aborted",
      "Could not delete OneSignal user",
    );
  }
});
