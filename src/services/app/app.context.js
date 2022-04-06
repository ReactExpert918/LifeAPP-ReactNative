import React, { useState, createContext, useEffect } from "react";
import { useSelector } from "react-redux";
import { firebaseSDK } from "../../libs/firebase";
import RNFS from "react-native-fs";
import { MEDIA_FOLDER } from "../../libs/firebase/storage";

export const HomeContext = createContext();

export const HomeContextProvider = ({ children }) => {
  const { user } = useSelector((state) => state.login_state);

  const [userInfo, setUserInfo] = useState(null);
  const [groups, setGroups] = useState([]);
  const [friends, setFriends] = useState([]);

  const createUser = (filePath) => {
    const title = user.fullname ?? user.username ?? user.email ?? user.phone;
    const message = user.about ?? "";
    const image_uri = `file://${filePath}`;

    setUserInfo({
      image_uri,
      title,
      message,
    });
  };

  const createGroups = (datas) => {
    let tempGroups = [];

    tempGroups.push({
      title: "Create Group",
      message: "Create a group for you and your friends.",
      isGroup: true,
    });

    datas.forEach((data) => {
      tempGroups.push({ name: data.name });
    });

    setGroups(tempGroups);
  };

  const createFriend = async (user_id) => {
    const results = await firebaseSDK.getFriends(user_id);
    console.log(results);
  };

  const downloadImage = async (fileName) => {
    const filePath = `${RNFS.DocumentDirectoryPath}/${fileName}`;
    const exists = await RNFS.exists(filePath);
    if (exists) {
      createUser(filePath);
    } else {
      const url = await firebaseSDK.getDownloadURL(
        `${MEDIA_FOLDER.USER}/${fileName}`
      );
      RNFS.downloadFile({ fromUrl: url, toFile: filePath })
        .promise.then((r) => {
          console.log(r);
          createUser(filePath);
        })
        .catch((error) => {
          console.log(error);
          createUser(null);
        });
    }
  };

  const setGroupsInformation = async (user_id) => {
    firebaseSDK
      .getMembers(user_id)
      .then((results) => {
        const chatIds = results.map((data) => data.chatId);
        firebaseSDK
          .getGroups(chatIds)
          .then((results) => {
            createGroups(results);
          })
          .catch(() => {
            console.log("Failed");
            createGroups([]);
          });
      })
      .catch((error) => {
        console.log("Error");
        createGroups([]);
      });
  };

  useEffect(() => {
    if (user && user != {}) {
      downloadImage(`${user.id}.jpg`);
      setGroupsInformation(user.id);
      createFriend(user.id);
    }
  }, [user]);

  return (
    <HomeContext.Provider value={{ userInfo, groups, friends }}>
      {children}
    </HomeContext.Provider>
  );
};
