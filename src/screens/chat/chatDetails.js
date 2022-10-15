import React from 'react';
import { Container } from '../../components';
import { View } from 'react-native';
import styled from 'styled-components/native';
import { styles } from './styles';
import { colors } from '../../assets/colors';
import { TextMessage } from './components/message/textMessage';
import { AvatarComponent } from './components/message/avatarComponent';
import { ChatInputComponent } from './components/message/chatInput';
import { SCREEN_HEIGHT, SCREEN_WIDTH } from '../../constants/app';

const MainContainer = styled.ScrollView`
  flex: 1;
  background-color: ${colors.bg.primary};
  padding: 10px;
`;

// const Container = styled.View`
//   align-items: center;
//   justify-content: ${(props) =>
//     props.data.username !== 'Andrea' ? 'flex-start' : 'flex-end'};
//   flex-direction: row;
//   border-radius: 12px;
//   width: ${(props) => props.maxWidth}
//   margin-bottom: 10px;
// `;

const maxWidth = SCREEN_WIDTH - 175;
const width = SCREEN_HEIGHT - 20;

export const ChatDetailsScreen = () => {
  const messages = [
    {
      username: 'Andrea',
      message: 'Hello World. Please Reply',
      createdAt: 1651303751619,
    },
    {
      username: 'Andrea2',
      message:
        'Have much experience in version controller, ticket, Api testing tools, Design tools, etc.',
      createdAt: 1651303751622,
    },
    { username: 'Andrea', message: 'Hello World.', createdAt: 1651303851635 },
    {
      username: 'Andrea',
      message: 'Hello World. Please ',
      createdAt: 1651303951655,
    },
    {
      username: 'Andrea2',
      message: 'Hello World. Please Reply',
      createdAt: 1651310751679,
    },
  ];

  return (
    <Container>
      <View style={styles.divider}></View>
      <View style={styles.mainContainer}>
        <View style={styles.topContainer}></View>
        <MainContainer>
          {/* {messages &&
            messages.map((item, index) => (
              <Container key={`chat-${index}`} data={item} maxWidth={width}>
                {item.username !== 'Andrea' ? (
                  <>
                    <AvatarComponent datas={item} maxWidth={maxWidth} />
                    <TextMessage data={item} maxWidth={maxWidth} />
                  </>
                ) : (
                  <>
                    <TextMessage data={item} maxWidth={maxWidth} />
                    <AvatarComponent datas={item} maxWidth={maxWidth} />
                  </>
                )}
              </Container>
            ))} */}
        </MainContainer>
        <ChatInputComponent />
      </View>
    </Container>
  );
};
