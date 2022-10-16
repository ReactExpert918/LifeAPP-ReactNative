import { React } from 'react';
import PropTypes from 'prop-types';
import { TouchableOpacity, View, Text, Image, StyleSheet } from 'react-native';
import { useNavigation } from '@react-navigation/native';

import { colors } from '../../../assets/colors';
import { images } from '../../../assets/pngs';
import { APP_NAVIGATION } from '../../../constants/app';
import { textStyles } from '../../../common/text.styles';

const styles = StyleSheet.create({
  container: {
    height: 60,
    width: '100%',
    alignItems: 'center',
    justifyContent: 'flex-start',
    flexDirection: 'row',
    padding: 20,
  },
  content: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  headerImage: {
    width: 48,
    height: 48,
    borderRadius: 24,
    marginRight: 10,
  },
  newMessage: {
    width: 24,
    height: 24,
    backgroundColor: colors.ui.primary,
    borderRadius: 12,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
  },
});

export const ChatItem = ({ data }) => {
  const navigation = useNavigation();
  const onNavigate = () => {
    navigation.navigate(APP_NAVIGATION.chat_detail, {
      chatId: data.chatId,
      accepterId: data.accepterId,
    });
  };

  return (
    <TouchableOpacity style={styles.container} onPress={onNavigate}>
      <Image style={styles.headerImage} source={images.ic_default_profile} />
      <View style={styles.content}>
        {data && (
          <View>
            <Text style={textStyles.blackBold}>{data.userFullname}</Text>
            <Text
              style={[
                textStyles.grayMediumThin,
                { color: colors.text.lightgray },
              ]}
            >
              {data.text}
            </Text>
          </View>
        )}
        {/* {data.new != 0 && (
          <View style={styles.newMessage}>
            <Text style={{ color: colors.text.white }}>{data.new}</Text>
          </View>
        )} */}
      </View>
    </TouchableOpacity>
  );
};

ChatItem.propTypes = {
  data: PropTypes.object.isRequired,
};
