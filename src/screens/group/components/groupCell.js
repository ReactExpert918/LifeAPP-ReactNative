import React from 'react';
import { Text } from '../../../components/typography/text.component';
import { images } from '../../../images';
import { Image, StyleSheet, View } from 'react-native';
import { colors } from '../../../assets/colors';

const styles = StyleSheet.create({
  container: {
    flex: 1 / 4,
    alignItems: 'center',
    justifyContent: 'center',
  },
  buttonAdd: {
    width: 70,
    height: 70,
    borderRadius: 35,
    borderWidth: 1,
    borderColor: colors.ui.border,
    marginBottom: 24,
    alignItems: 'center',
    justifyContent: 'center',
  },
  imageAdd: {
    width: 30,
    height: 30,
  },
});

export const GROUP_CELL_TYPE = {
  add: 'add',
  member: 'member',
};

export const GroupCellComponent = ({ item }) => {
  const { type, friend_id } = item;
  return (
    <View style={styles.container}>
      <View style={styles.buttonAdd}>
        <Image
          source={
            type == GROUP_CELL_TYPE.add
              ? images.ic_add_group
              : images.ic_default_profile
          }
          style={styles.imageAdd}
        />
      </View>
      <Text variant="label" color={colors.text.black}>
        {type == GROUP_CELL_TYPE.add ? 'ADD' : 'CELL'}
      </Text>
    </View>
  );
};
