import { React, useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { TouchableOpacity, View, Text, Image, StyleSheet } from 'react-native';
import { useNavigation } from '@react-navigation/native';

import { colors } from '../../../assets/colors';
import { images } from '../../../assets/pngs';
import { APP_NAVIGATION } from '../../../constants/app';
import { textStyles } from '../../../common/text.styles';
import { firebaseSDK } from '../../../services/firebase';
import { MEDIA_FOLDER } from '../../../services/firebase/storage';
import { getImagePath } from '../../../utils/media';

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
  const [display, setDisplay] = useState(null);
  const [image_uri, setImage_url] = useState(null);


  const setImage = async (fileName) => {
    const path = await getImagePath(fileName, MEDIA_FOLDER.USER);
    if (path) {
      setImage_url(path);
    }
  };

  const onNavigate = () => {
    navigation.navigate(APP_NAVIGATION.chat_detail, {
      chatId: data.chatId,
      accepterId: data.user_id,
    });
  };

  useEffect(() => {
    async function fetch() {
      let result = await firebaseSDK.getUser(data.user_id);
      console.log(result);
      await setDisplay(result);
      console.log(display);
      await setImage(`${display.objectId}.jpg`);
    }
    fetch();
  }, []);

  return (
    <TouchableOpacity style={styles.container} onPress={onNavigate}>
      {
        image_uri ?
          (
            <Image
              style={styles.headerImage}
              source={{uri: image_uri} }
            />
          ) : 
          (
            <Image
              style={styles.headerImage}
              source={images.ic_default_profile}
            />
          )
      }
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
