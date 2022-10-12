import React from 'react';
import { ContainerComponent } from '../../components/container.component';
import { View, ScrollView } from 'react-native';
import { ChatHeaderComponent } from './component/chatHeadComponent';
import { SearchbarComponent } from './component/chatSearchComponent';
import { chatStyle } from './styled';
import { ChatSection } from './chatSection';

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
  ];
  return (
    <ContainerComponent>
      <ChatHeaderComponent />
      <View style={chatStyle.divider}></View>
      <View style={chatStyle.mainContainer}>
        <View style={chatStyle.topContainer}>
          <SearchbarComponent />
        </View>
        <View style={chatStyle.container}>
          <View style={chatStyle.divider}></View>
          <ScrollView style={{ marginTop: 20 }}>
            {recommandFriend.length > 0 && (
              <ChatSection items={recommandFriend} onNavigate={null} />
            )}
          </ScrollView>
        </View>
      </View>
    </ContainerComponent>
  );
};
