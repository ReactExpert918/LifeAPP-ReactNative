import { React } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';
import { HeaderComponent } from '../../../components/header.component';
import { colors } from '../../../assets/colors';

const FriendHeaderStyle = StyleSheet.create({
  editText: {
    position: 'absolute',
    left: 20,
    size: 25,
    color: colors.text.white,
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
    fontWeight: 'bold',
  },
  container: {
    height: 60,
    width: '100%',
    alignItems: 'center',
    justifyContent: 'center',
    flexDirection: 'row',
    backgroundColor: colors.ui.primary,
  },
});

export const ChatHeaderComponent = () => {
  return (
    <View style={FriendHeaderStyle.container}>
      <Ionicons
        name="md-chevron-back-sharp"
        size={25}
        style={FriendHeaderStyle.editText}
      />
      <Text style={FriendHeaderStyle.text}>Chats</Text>
      <Ionicons
        name="md-create-outline"
        size={25}
        style={FriendHeaderStyle.iconClose}
      />
    </View>
  );
};
