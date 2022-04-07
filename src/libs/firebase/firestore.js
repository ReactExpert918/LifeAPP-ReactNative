import firestore from "@react-native-firebase/firestore";
import { deleteAuthedUser } from "./auth";

export const FIRESTORE_ACTION = {
  ADD: "Add",
  DEL: "Del",
  UDT: "Udt",
};

const FIRESTORE_TABLES = {
  USER: "Person",
  Friend: "Friend",
  Group: "Group",
  Member: "Member",
  Message: "Message",
  Detail: "Detail",
  Payment_Method: "PaymentMethod",
  Single: "Single",
  Stripe_Customer: "StripeCustomer",
  ZEDPay: "ZedPay",
};

export const createUser = (user) => {
  return new Promise((resolve, reject) => {
    firestore()
      .collection(FIRESTORE_TABLES.USER)
      .add(user)
      .then(() => resolve())
      .catch((error) => reject(error));
  });
};

export const deleteUser = (user_id) => {
  return new Promise((resolve, reject) => {
    firestore()
      .collection(FIRESTORE_TABLES.USER)
      .doc(user_id)
      .then(() => {
        console.log("User Deleted");
      })
      .catch((error) => {
        console.log(error);
      });
    deleteAuthedUser()
      .then(() => {
        resolve();
      })
      .catch((error) => {
        reject(error);
      });
  });
};

export const getUser = (user_id) => {
  return new Promise((resolve, reject) => {
    firestore()
      .collection(FIRESTORE_TABLES.USER)
      .doc(user_id)
      .get()
      .then((snapshot) => {
        if (snapshot.exists) {
          const user = {
            id: user_id,
            ...snapshot.data(),
          };
          resolve(user);
        }
        reject("No exists");
      })
      .catch((error) => reject(error));
  });
};

export const getUsers = (userIds) => {
  return new Promise((resolve, reject) => {
    firestore()
      .collection(FIRESTORE_TABLES.USER)
      .where("objectId", "in", userIds)
      .get()
      .then((snapshot) => {
        let results = [];
        snapshot.forEach((data) => {
          results.push(data.data());
        });
        resolve(results);
      })
      .catch((error) => reject(error));
  });
};

export const setUser = (userInfo) => {
  return new Promise((resolve, reject) => {
    firestore()
      .collection(FIRESTORE_TABLES.USER)
      .doc(userInfo.objectId)
      .set(userInfo)
      .then((user) => {
        resolve(user);
      })
      .catch((error) => {
        reject(error);
      });
  });
};

export const getMembers = (user_id) => {
  return new Promise((resolve, reject) => {
    firestore()
      .collection(FIRESTORE_TABLES.Member)
      .where("userId", "==", user_id)
      .get()
      .then((querySnapshot) => {
        let result = [];
        querySnapshot.forEach((documentSnapshot) => {
          result.push(documentSnapshot.data());
        });

        resolve(result);
      })
      .catch((error) => {
        console.log(error);
        reject(error);
      });
  });
};

export const getFriends = async (user_id) => {
  let results = [];

  const query1 = await firestore()
    .collection(FIRESTORE_TABLES.Friend)
    .where("userId", "==", user_id)
    .where("isAccepted", "==", true)
    .get();

  query1.forEach((docSnap) => {
    results.push(docSnap.data());
  });

  const query2 = await firestore()
    .collection(FIRESTORE_TABLES.Friend)
    .where("friendId", "==", user_id)
    .where("isAccepted", "==", true)
    .get();

  query2.forEach((docSnap) => {
    results.push(docSnap.data());
  });

  return results;
};

export const getSingles = async (user_id) => {
  let results = [];

  const query1 = await firestore()
    .collection(FIRESTORE_TABLES.Single)
    .where("userId1", "==", user_id)
    .get();

  query1.forEach((docSnap) => {
    results.push(docSnap.data());
  });

  const query2 = await firestore()
    .collection(FIRESTORE_TABLES.Single)
    .where("userId2", "==", user_id)
    .get();

  query2.forEach((docSnap) => {
    results.push(docSnap.data());
  });

  return results;
};

export const getGroups = (chatIDs) => {
  return new Promise((resolve, reject) => {
    firestore()
      .collection(FIRESTORE_TABLES.Group)
      .where("chatId", "in", chatIDs)
      .get()
      .then((querySnapshot) => {
        let result = [];
        querySnapshot.forEach((documentSnapshot) => {
          result.push(documentSnapshot.data());
        });

        resolve(result);
      })
      .catch((error) => {
        console.log(error);
        reject(error);
      });
  });
};

export const getGroup = (group_id) => {
  console.log(group_id);
  return new Promise((resolve, reject) => {
    firestore()
      .collection(FIRESTORE_TABLES.Group)
      .doc(group_id)
      .get()
      .then((snapshot) => {
        if (snapshot.exists) {
          const group = {
            id: group_id,
            ...snapshot.data(),
          };
          resolve(group);
        }
        reject("No exists");
      })
      .catch((error) => reject(error));
  });
};

export const getLastMessasge = (chatId) => {
  return new Promise((resolve, reject) => {
    firestore()
      .collection(FIRESTORE_TABLES.Message)
      .where("chatId", "==", chatId)
      .orderBy("updatedAt", "desc")
      .limit(1)
      .get()
      .then((querySnapshot) => {
        let result;
        querySnapshot.forEach((documentSnapshot) => {
          result = documentSnapshot.data();
        });
        if (result) {
          resolve(result);
        } else {
          reject("No message");
        }
      })
      .catch((error) => {
        console.log(error);
        reject(error);
      });
  });
};
