import React, { useEffect, useState } from 'react';
import { View } from 'react-native';
import firestore from '@react-native-firebase/firestore';

import { Container, Header, SearchBar } from '../../components';
import { styles } from './styles';
import { KeyboardAwareFlatList } from 'react-native-keyboard-aware-scroll-view';
import { Message } from './components/message';
import { ChatInput } from './components/chatInput';
import { useNavigation, useRoute } from '@react-navigation/native';

export const ChatDetailsScreen = () => {
  const navigation = useNavigation();
  const route = useRoute();
  const { chatId } = route.params;
  const [messages, setMessages] = useState([]);

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
        <ChatInput />
      </View>
    </Container>
  );
};
