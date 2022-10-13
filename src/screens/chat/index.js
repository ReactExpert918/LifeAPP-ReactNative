import React from 'react';
import { ContainerComponent } from '../../components/container.component';
import { View, ScrollView } from 'react-native';
import { ChatHeaderComponent } from './component/chatHeadComponent';
import { SearchbarComponent } from './component/chatSearchComponent';
import { chatStyle } from './styled';
import { APP_NAVIGATION } from '../../constants/app';
import { PersonComponent } from './component/personComponent';

export const ChatScreen = ({ navigation }) => {
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
  const onNavigate = (name) => {
    console.log(name);
    navigation.navigate(APP_NAVIGATION.chat_detail, {name});
  };
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
            {
              recommandFriend.length > 0 && (
                recommandFriend.map((data, index) => 
                  <PersonComponent
                    CELLInfo={data}
                    key={`data-${index}`}
                    onNavigate={onNavigate}
                    name={data.username}
                  />
                )
              )}
          </ScrollView>
        </View>
      </View>
    </ContainerComponent>
  );
};
