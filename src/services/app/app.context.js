import React, { useState, createContext, useEffect } from "react";
import { useSelector } from "react-redux";
import { PERSONCELLTYPE } from "../../features/home/components/person.component";
import { firebaseSDK } from "../../libs/firebase";

export const HomeContext = createContext();

export const HomeContextProvider = ({ children }) => {
  const { user } = useSelector((state) => state.login_state);

  const [userInfo, setUserInfo] = useState(null);
  const [groups, setGroups] = useState([]);
  const [friends, setFriends] = useState([]);

  const [chats, setChats] = useState([]);

  const createUser = () => {
    setUserInfo({
      ...user,
      type: PERSONCELLTYPE.user,
    });
  };

  const createGroups = async (datas) => {
    let tempGroups = [];

    tempGroups.push({
      title: "Create Group",
      message: "Create a group for you and your friends.",
      type: PERSONCELLTYPE.group_header,
    });

    datas.forEach(async (data) => {
      tempGroups.push({ ...data, type: PERSONCELLTYPE.group });
    });

    setGroups(tempGroups);
    addChats(datas);
  };

  const createFriends = async (members) => {
    const friendIds = members.map((data) => {
      if (!data.isDeleted) {
        return data.friendId == user.id ? data.userId : data.friendId;
      }
    });

    const users = await firebaseSDK.getUsers(friendIds);
    let tempFriends = [];

    users.forEach(async (data) => {
      const person = {
        ...data,
        type: PERSONCELLTYPE.friend,
      };

      tempFriends.push(person);
    });

    setFriends(tempFriends);
  };

  const addChats = async (datas) => {
    let newChat = chats;

    datas.forEach(async (data) => {
      const chat_id = data.chatId ?? data.objectId;

      console.log(data);

      const message = await getLastMessasge(chat_id);

      newChat.push({
        ...message,
        type: PERSONCELLTYPE.chats,
        user_id:
          data.userId1 == user.id
            ? data.userId2
            : data.userId1 ?? data.objectId,
        isGroup: data.userId1 == null,
      });
    });

    newChat.sort((a, b) => a.createdAt > b.createdAt);
    setChats(newChat);
  };

  const getLastMessasge = async (chat_id) => {
    const message = await firebaseSDK.getLastMessasge(chat_id);
    return message;
  };

  const getFriends = async (user_id) => {
    const results = await firebaseSDK.getFriends(user_id);

    createFriends(results);
  };

  const getSingles = async (user_id) => {
    const singles = await firebaseSDK.getSingles(user_id);
    addChats(singles);
  };

  const getGroups = async (user_id) => {
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
      setChats([]);
      createUser(user.id);
      getGroups(user.id);
      getFriends(user.id);
      getSingles(user.id);
    }
  }, [user]);

  return (
    <HomeContext.Provider value={{ userInfo, groups, friends, chats }}>
      {children}
    </HomeContext.Provider>
  );
};
