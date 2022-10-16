import React, { useContext } from 'react';
import { ScrollView } from 'react-native';

import { Container, Header, SearchBar } from '../../components';
import { HomeContext } from '../../context/home';
import { ChatItem } from './components/chatItem';
import { styles } from './styles';

export const ChatScreen = () => {
  const { chats } = useContext(HomeContext);

  return (
    <Container>
      <Header title="Chats" />
      <SearchBar />
      <ScrollView contentContainerStyle={styles.container}>
        {chats.length > 0 &&
          chats.map((data, index) => (
            <ChatItem data={data} key={`chat-list-${index}`} />
          ))}
      </ScrollView>
    </Container>
  );
};
