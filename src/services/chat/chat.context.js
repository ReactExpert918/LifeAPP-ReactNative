import React, { useState, createContext, useEffect } from "react";
import { DB_INTERNAL } from "../../libs/database";
import firestore from "@react-native-firebase/firestore";

export const ChatContext = createContext();

export const ChatContextProvider = ({ route, children }) => {
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
          console.log(msgs);
          setMessages(msgs);
        });

      // Stop listening for updates when no longer required
      return () => subscriber();
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
