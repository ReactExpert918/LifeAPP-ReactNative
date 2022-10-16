import React, {useState, useEffect} from 'react';
import { useSelector } from 'react-redux';
import { ContainerComponent } from '../../components/container.component';
import { View, ScrollView, Text, Dimensions } from 'react-native';
import styled from 'styled-components/native';
import { ChatHeaderComponent } from './component/chatHeadComponent';
import { SearchbarComponent } from './component/chatSearchComponent';
import { chatStyle } from './styled';
import { colors } from '../../assets/colors';
import { TextMessage } from './component/message/textMessage';
import { AvatarComponent } from './component/message/avatarComponent';
import { ChatInputComponent } from './component/message/chatInput';
import { firebaseSDK } from '../../services/firebase';

const MainContainer = styled.ScrollView`
  flex: 1;
  background-color: ${colors.bg.primary};
  padding: 10px; 
`;

const Container = styled.View`
  align-items: center;
  justify-content: ${(props) => (props.data.username !== 'Andrea' ? 'flex-start' : 'flex-end')};
  flex-direction: row;
  border-radius: 12px;
  width: ${(props) => props.maxWidth}
  margin-bottom: 10px;
`;

export const ChatDetailsScreen = ({ route }) => {
  // const { name } = route.params; 
  const acceptInfo = useSelector((state) => state.Chat.payload);
  const {user} = useSelector((state) => state.Auth);
  const [messages, setMessages] = useState([]);

  useEffect(async() => {
    let result = await firebaseSDK.getSingle(user.uid, acceptInfo.object.objectId);
    let message = await firebaseSDK.getSingleChats(result.chatId);
    console.log(message);
    if(message) {
      setMessages(message);
    }
  }, []);

  console.log(acceptInfo.object, user);

  const submit = (text) => {
    console.log(text);
  };
  // const messages = [
  //   { username: 'Andrea', message: 'Hello World. Please Reply', createdAt: 1651303751619 },
  //   {
  //     username: 'Andrea2',
  //     message:
  //       'Have much experience in version controller, ticket, Api testing tools, Design tools, etc.',
  //     createdAt: 1651303751622
  //   },
  //   { username: 'Andrea', message: 'Hello World.', createdAt: 1651303851635 },
  //   { username: 'Andrea', message: 'Hello World. Please ', createdAt: 1651303951655 },
  //   { username: 'Andrea2', message: 'Hello World. Please Reply', createdAt: 1651310751679 },
  // ];
  const maxWidth = Dimensions.get('window').width - 175;
  const width = Dimensions.get('window').width - 20;
  return (
    <ContainerComponent>
      <ChatHeaderComponent title={acceptInfo.object.fullname}/>
      <View style={chatStyle.divider}></View>
      <View style={chatStyle.mainContainer}>
        <View style={chatStyle.topContainer}>
          <SearchbarComponent />
        </View>
        <MainContainer>
          {
            messages && (
              messages.map((item, index) => 
              
                <Container  key={`data0-${index}`} data={item} maxWidth={width}>
                  {
                    item.username !== 'Andrea' ? (
                      <>
                        <AvatarComponent 
                          datas={item} 
                          maxWidth={maxWidth}
                          key={`data1-${index}`}
                        />
                        <TextMessage 
                          data={item}
                          key={`data2-${index}`}
                          maxWidth={maxWidth}
                        />
                      </>                       
                    ) : (
                      <>
                        <TextMessage 
                          data={item}
                          key={`data2-${index}`}
                          maxWidth={maxWidth}
                        />
                        <AvatarComponent 
                          datas={item} 
                          maxWidth={maxWidth}
                          key={`data1-${index}`}
                        />
                      </>
                    )
                  }
                </Container>
              
              )
            )
          }
        </MainContainer>
        <ChatInputComponent onSubmit={submit} />
      </View>
    </ContainerComponent>
  );
};