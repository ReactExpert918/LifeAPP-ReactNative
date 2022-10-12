import React from 'react';
import { View, Text } from 'react-native';
import { useSelector } from 'react-redux';
import { textStyles } from '../../common/text.styles';
import { Avatar, Spacer } from '../../components';
import { SearchbarComponent } from '../chat/component/chatSearchComponent';
import { APP_NAVIGATION } from '../../constants/app';
import { HeaderComponent } from '../../components/header.component';
import { styles } from './styles';

export const HomeScreen = ({ navigation }) => {
  const { user } = useSelector((state) => state.Auth);
  const onClickSetting = () => {
    navigation.navigate(APP_NAVIGATION.setting);
  };
  const onClickFriend = () => {
    navigation.navigate(APP_NAVIGATION.friend_add);
  };
  console.log(user);
  return (
    <View style={styles.container}>
      <HeaderComponent title='Home' firstClick={onClickSetting} secondClick={onClickFriend} />
      <View style={styles.topContainer}>
        <SearchbarComponent />
      </View>
      <View style={styles.profileContainer}>
        <Avatar size={50} url={user.pictureAt} />
        <Spacer right={16} />
        <View>
          <Text style={textStyles.blackBold}>
            {user.fullname || user.username}
          </Text>
          <Text style={textStyles.grayMediumThin}></Text>
        </View>
      </View>
    </View>
  );
};
