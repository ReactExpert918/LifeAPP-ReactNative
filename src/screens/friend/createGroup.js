import { React } from 'react';
import { TouchableOpacity, Text, Image, View, StyleSheet } from 'react-native';
import { images } from '../../assets/pngs';
import { createGroup } from './style';

export const CreateGroup = ({ onNavigate }) => {
  return (
    <TouchableOpacity style={createGroup.container} onPress={onNavigate}>
      <Image style={createGroup.headerImage} source={images.ic_create_group} />
      <View>
        <Text style={{ color: 'black' }}>Create Group</Text>
        <Text>Create a group for you and your friends.</Text>
      </View>
    </TouchableOpacity>
  );
};
