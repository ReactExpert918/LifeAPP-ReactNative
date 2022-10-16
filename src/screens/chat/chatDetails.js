import React, { useEffect, useState } from 'react';
import { View } from 'react-native';
import firestore from '@react-native-firebase/firestore';
import uuid from 'react-native-uuid';
import { useSelector } from 'react-redux';
import { useNavigation, useRoute } from '@react-navigation/native';
import { KeyboardAwareFlatList } from 'react-native-keyboard-aware-scroll-view';

import { Container, Header, SearchBar } from '../../components';
import { styles } from './styles';
import { Message } from './components/message';
import { ChatInput } from './components/chatInput';
import { firebaseSDK } from '../../services/firebase';

const initMessage = {
  chatId: '',

  userId: '',
  userFullname: '',
  userInitials: '',
  userPictureAt: 0,

  type: '',
  text: '',

  photoWidth: 0,
  photoHeight: 0,
  videoDuration: 0,
  audioDuration: 0,

  latitude: 0,
  longitude: 0,

  isMediaQueued: false,
  isMediaFailed: false,

  isDeleted: false,
  isObjectionable: false,
  createdAt: new Date().getTime(),
  updatedAt: new Date().getTime(),
};

export const ChatDetailsScreen = () => {
  const navigation = useNavigation();
  const route = useRoute();
  const { user } = useSelector((state) => state.Auth);
  const { chatId } = route.params;
  const [messages, setMessages] = useState([]);
  const [text, setText] = useState('');

  useEffect(() => {
    const subscriber = firestore()
      .collection('Message')
      .where('chatId', '==', chatId)
      .orderBy('updatedAt', 'desc')
      .limit(12)
      .onSnapshot((querySnapshot) => {
        let msgs = [];
        querySnapshot.forEach((documentSnapshot) => {
          msgs.push(documentSnapshot.data());
        });
        setMessages(msgs);
      });

    return () => subscriber();
  }, []);

  const onGoBack = () => {
    navigation.goBack();
  };

  const onSendTextMessage = (text) => {
    initMessage.objectId = uuid.v4().toUpperCase();
    initMessage.text = text;
    initMessage.chatId = chatId;
    initMessage.type = 'text';
    initMessage.userFullname = user.fullname;
    initMessage.userId = user.objectId;
    firebaseSDK.createMessage(initMessage);
    setText('');
  };

  return (
    <Container>
      <Header firstClick={onGoBack} />
      <SearchBar />
      <View style={styles.container}>
        <KeyboardAwareFlatList
          style={{ flex: 1 }}
          data={messages}
          renderItem={(item) => <Message message={item} />}
          keyExtractor={(item) => `message-${item.objectId}`}
          inverted
          contentContainerStyle={{ paddingTop: 4 }}
        />
        <ChatInput
          text={text}
          setText={setText}
          onSubmitChat={onSendTextMessage}
        />
      </View>
    </Container>
  );
};
