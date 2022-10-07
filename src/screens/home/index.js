import React from 'react';
import { View, Text } from 'react-native';
import { useSelector } from 'react-redux';
import { textStyles } from '../../common/text.styles';
import { Avatar, Spacer } from '../../components';
import { Header, SearchBar } from './components';
import { styles } from './styles';

export const HomeScreen = () => {
  const { user } = useSelector((state) => state.Auth);
  return (
    <View style={styles.container}>
      <Header title={'Home'} />
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
    </View>
  );
};
