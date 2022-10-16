import React, { useState } from 'react';
import styled from 'styled-components/native';

import { SafeAreaView } from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';
import { colors } from '../../../../assets/colors';
import { TouchableOpacity } from 'react-native';

const InputAreaContainer = styled.View`
  width: 100%;
  max-height: 100px;
  flex-direction: row;
  align-items: center;
  max-height: 100px;
  border-top-color: ${colors.text.lightgray};
  border-top-width: 1px;
  margin-top: 20px;
`;

const Input = styled.TextInput`
  flex: 1;
  flex-grow: 1;
  flex-wrap: wrap;
  border-radius: 16px;
  flex-wrap: wrap;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-horizontal: 12px;
  border-color: ${colors.ui.gray};
  border-width: 1px;
  margin-top: 6px;
  margin-bottom: 6px;
  margin-right: 4px;
  font-size: 16px
`;

const IconAttach = styled(Ionicons).attrs({
  name: 'md-attach-sharp',
  size: 30,
  color: colors.ui.gray,
})``;

const AttachContainer = styled.View`
  padding: 4px;
  margin-left: 4px;
  margin-right: 4px;
  border-radius: 18px;
`;

const AttachContainerCam = styled.View`
  paddingRight: 8px;
  margin-right: 4px;
  border-radius: 18px;
`;

const IconMic = styled(Ionicons).attrs({
  name: 'md-mic',
  size: 30,
  color: colors.ui.primary,
})``;

const IconCam = styled(Ionicons).attrs({
  name: 'md-camera-outline',
  size: 30,
  color: colors.ui.primary,
})``;

const MicContainer = styled.View`
  padding: 4px;
  margin-left: 4px;
  margin-right: 4px;
  border-radius: 18px;
`;

const IconSend = styled(Ionicons).attrs({
  name: 'md-arrow-up',
  size: 28,
  color: colors.ui.white,
})``;

const SendContainer = styled.View`
  padding: 4px;
  background-color: ${colors.ui.primary};
  margin-left: 4px;
  margin-right: 4px;
  border-radius: 18px;
`;

export const ChatInputComponent = ({onSubmit}) => {
  const [message, onSetMessage] = useState('');
  const onSubmitChat = () => {
    onSubmit(message);
    onSetMessage('');
    this.textInput.clear();
  };
  return (
    <SafeAreaView style={{ backgroundColor: colors.bg.primary }}>
      <InputAreaContainer>
        <TouchableOpacity>
          <AttachContainer>
            <IconAttach />
          </AttachContainer>
        </TouchableOpacity>
        <TouchableOpacity>
          <AttachContainerCam>
            <IconCam />
          </AttachContainerCam>
        </TouchableOpacity>
        <Input
          ref={input => { this.textInput = input; }}
          returnKeyType={'default'}
          keyboardType="default"
          multiline
          placeholder="Enter a Message"
          onChangeText={(text) => onSetMessage(text)}
          onSubmitEditing={onSubmitChat}
          value={message}
        />
        
        <TouchableOpacity>
          <MicContainer>
            <IconMic />
          </MicContainer>
        </TouchableOpacity>
   
      </InputAreaContainer>
    </SafeAreaView>
  );
};
