import React, { useState, createContext, useEffect } from "react";
import { DB_INTERNAL } from "../../libs/database";
import firestore from "@react-native-firebase/firestore";
import database from "@react-native-firebase/database";

export const ChatContext = createContext();

export const ChatContextProvider = ({ route, children, navigation }) => {
  const { chatId, accepterId } = route.params;

  const [title, setTitle] = useState("");

  const [messages, setMessages] = useState([]);

  useEffect(() => {
    setMessageTitle();
  }, [chatId, accepterId]);

  useEffect(() => {
    if (chatId) {
      const subscriber = firestore()
        .collection("Message")
        .where("chatId", "==", chatId)
        .orderBy("updatedAt", "desc")
        .limit(12)
        .onSnapshot((querySnapshot) => {
          let msgs = [];
          querySnapshot.forEach((documentSnapshot) => {
            msgs.push(documentSnapshot.data());
          });
          setMessages(msgs);
        });

      // Stop listening for updates when no longer required
      return () => subscriber();
    }
  }, [chatId]);

  useEffect(() => {
    if (chatId) {
      const onChildAdded = database()
        .ref(`/video_call/${chatId}`)
        .on("child_added", (snapshot) => {
          navigation.push("VideoCall", {
            chatId,
            receptId: "",
            outGoing: false,
          });
        });

      // Stop listening for updates when no longer required
      return () =>
        database()
          .ref(`/video_call/${chatId}`)
          .off("child_added", onChildAdded);
    }
  }, [chatId]);

  const setMessageTitle = async () => {
    if (accepterId && accepterId != "") {
      const personName = await DB_INTERNAL.getPersonName(accepterId);
      setTitle(personName);
    } else {
      const titleGet = await DB_INTERNAL.getGroupName(chatId);

      setTitle(titleGet);
    }
  };

  return (
    <ChatContext.Provider value={{ title, messages }}>
      {children}
    </ChatContext.Provider>
  );
};
