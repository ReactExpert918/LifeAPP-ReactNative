import React from 'react';
import { ScrollView } from 'react-native';

import { Container, Header, SearchBar } from '../../components';
import { ChatItem } from './components/chatItem';
import { styles } from './styles';

export const ChatScreen = () => {
  const recommandFriend = [
    { username: 'Andrea', message: 'Hello World. Please Reply', new: 3 },
    {
      username: 'Andrea2',
      message:
        'Have much experience in version controller, ticket, Api testing tools, Design tools, etc.',
      new: 2,
    },
    { username: 'Andrea3', message: 'Hello World. Please Reply', new: 1 },
    { username: 'Andrea4', message: 'Hello World. Please Reply', new: 0 },
    { username: 'Andrea5', message: 'Hello World. Please Reply', new: 0 },
    { username: 'Andrea3', message: 'Hello World. Please Reply', new: 1 },
    { username: 'Andrea4', message: 'Hello World. Please Reply', new: 0 },
    { username: 'Andrea5', message: 'Hello World. Please Reply', new: 0 },
    { username: 'Andrea3', message: 'Hello World. Please Reply', new: 1 },
    { username: 'Andrea4', message: 'Hello World. Please Reply', new: 0 },
    { username: 'Andrea5', message: 'Hello World. Please Reply', new: 0 },
    { username: 'Andrea3', message: 'Hello World. Please Reply', new: 1 },
    { username: 'Andrea4', message: 'Hello World. Please Reply', new: 0 },
    { username: 'Andrea5', message: 'Hello World. Please Reply', new: 0 },
  ];

  return (
    <Container>
      <Header title="Chats" />
      <SearchBar />
      <ScrollView contentContainerStyle={styles.container}>
        {recommandFriend.length > 0 &&
          recommandFriend.map((data, index) => (
            <ChatItem data={data} key={`friend-${index}`} />
          ))}
      </ScrollView>
    </Container>
  );
};
