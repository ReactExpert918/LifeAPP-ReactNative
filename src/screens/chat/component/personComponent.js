/* eslint-disable react/prop-types */
import { React } from 'react';
import { colors } from '../../../assets/colors';
import { images } from '../../../assets/pngs';
import { TouchableOpacity, View, Text, Image } from 'react-native';
import { personComponentStyle } from './chatComponentStyled';

export const PersonComponent = ({CELLInfo, onNavigate}) => {
  return(
    <TouchableOpacity 
      style={personComponentStyle.container} 
      onPress={onNavigate}
    >
      <Image 
        style={personComponentStyle.headerImage} 
        source={images.ic_default_profile}
      />
      <View style={{flex:1, flexDirection: 'row', justifyContent: 'space-between', }}>
        {CELLInfo && (
          <View>
            <Text variant="label" style={{color: colors.text.black}}>
              {CELLInfo.username}
            </Text>
            <Text variant="hint" style={{color: colors.text.lightgray}}>
              {CELLInfo.message.length < 35 ? CELLInfo.message : `${CELLInfo.message.slice(0, 35)} ...`}
            </Text>
          </View>
        )}
        {CELLInfo.new != 0 && (
          <View style={personComponentStyle.newMessage}>
            <Text style={{color: colors.text.white}}>{CELLInfo.new}</Text>
          </View>
        )}
      </View>
    </TouchableOpacity>
       
  );
};
