import { React } from 'react';
import { StyleSheet, Text } from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';
import { HeaderComponent } from '../../../components/header.component';
import { colors } from '../../../assets/colors';

const FriendHeaderStyle = StyleSheet.create({
  iconSetting: {
    size: 24,
    color: colors.ui.white,
    position: 'absolute',
    left: 20,
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
});

export const FriendHeader = ({ back, title }) => {
  return (
    <HeaderComponent>
      {title == 'Add Friends' && (
        <Ionicons
          name="md-settings-outline"
          size={25}
          style={FriendHeaderStyle.iconSetting}
        />
      )}
      {title == 'Search Friends' && (
        <Ionicons
          name="md-chevron-back-sharp"
          size={25}
          style={FriendHeaderStyle.iconSetting}
          onPress={back}
        />
      )}
      <Text style={FriendHeaderStyle.text}>{title}</Text>
      {title == 'Add Friends' && (
        <Ionicons
          name="md-close"
          size={25}
          style={FriendHeaderStyle.iconClose}
        />
      )}
    </HeaderComponent>
  );
};
