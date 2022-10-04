import { React } from 'react';
import { colors } from '../../../assets/colors';
import { images } from '../../../assets/pngs';
import { TouchableOpacity, View, Text, Image } from 'react-native';
import { personComponentStyle } from './friendComponentStyle';

export const PersonComponent = ({ CELLInfo, onNavigate }) => {
  return (
    <TouchableOpacity
      style={personComponentStyle.container}
      onPress={onNavigate}
    >
      <Image
        style={personComponentStyle.headerImage}
        source={images.ic_default_profile}
      />
      <View
        style={{
          flex: 1,
          flexDirection: 'row',
          justifyContent: 'space-between',
        }}
      >
        {CELLInfo && (
          <Text variant="label" style={{ color: colors.text.black }}>
            {CELLInfo.username}
          </Text>
        )}
        <TouchableOpacity>
          <Image
            style={personComponentStyle.addImage}
            source={images.ic_add_friend}
          />
        </TouchableOpacity>
      </View>
    </TouchableOpacity>
  );
};
