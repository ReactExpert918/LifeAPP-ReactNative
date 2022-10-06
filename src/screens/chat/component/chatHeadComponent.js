import { React } from 'react';
import { StyleSheet, Text } from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';
import { HeaderComponent } from '../../../components/header.component';
import { colors } from '../../../assets/colors';

const FriendHeaderStyle = StyleSheet.create({
  editText: {
    position: 'absolute',
    left: 20,
    fontSize: 18,
    color: colors.text.white
  },
  iconClose: {
    size: 24,
    color: colors.ui.white,
    position: 'absolute',
    right: 20,
  },
  text: {
    fontSize: 20,
    color: colors.text.white,
    fontWeight: 'bold'
  }
});

export const ChatHeaderComponent = () => {

  return(
    <HeaderComponent>
      <Text
        style={FriendHeaderStyle.editText}
      >
                Edit
      </Text>
      <Text 
        style={FriendHeaderStyle.text}
      >
                Chats
      </Text>
      <Ionicons 
        name="md-create-outline" 
        size={25} 
        style={FriendHeaderStyle.iconClose}
      />
    </HeaderComponent>
  );
};