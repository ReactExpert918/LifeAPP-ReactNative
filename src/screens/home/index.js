import React from 'react';
import { View, Text } from 'react-native';
import { useSelector } from 'react-redux';
import { useNavigation } from '@react-navigation/native';

import { textStyles } from '../../common/text.styles';
import { Avatar, SearchBar, Spacer, Header, Container } from '../../components';
import { APP_NAVIGATION } from '../../constants/app';
import { Friends, Groups } from './components';
import { styles } from './styles';

export const HomeScreen = () => {
  const { user } = useSelector((state) => state.Auth);
  const navigation = useNavigation();

  const onClickSetting = () => {
    navigation.navigate(APP_NAVIGATION.setting);
  };

  const onClickFriend = () => {
    navigation.navigate(APP_NAVIGATION.friend_add);
  };

  return (
    <Container>
      <Header
        title="Home"
        firstClick={onClickSetting}
        secondClick={onClickFriend}
      />
      <SearchBar />
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
      <Friends />
      <Groups />
    </Container>
  );
};
