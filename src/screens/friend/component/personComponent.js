/* eslint-disable react/prop-types */
import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { colors } from '../../../assets/colors';
import { images } from '../../../assets/pngs';
import { TouchableOpacity, View, Text, Image } from 'react-native';
import { personComponentStyle } from './friendComponentStyle';
import Ionicons from 'react-native-vector-icons/Ionicons';
import { FRIEND_STATE } from '../../../constants/redux';
import { firebaseSDK } from '../../../services/firebase';
import { MEDIA_FOLDER } from '../../../services/firebase/storage';
import { getImagePath } from '../../../utils/media';

export const PersonComponent = ({ CELLInfo, onNavigate, visible, state }) => {
  const dispatch = useDispatch();
  const { user } = useSelector((state) => state.Auth);
  const [image_uri, setImage_url] = useState(null);
  const [name, setName] = useState(null);
  const [canAdd, setCanAdd] = useState(false);

  const toggleShow = () => {
    dispatch({
      type: FRIEND_STATE.REQUEST,
      show: true,
      data: CELLInfo
    });
  };

  useEffect(() => {
    if (CELLInfo && CELLInfo != {}) {
      setName(CELLInfo.username);
      setImage(`${CELLInfo.objectId}.jpg`);
      checkFriend(user.uid, CELLInfo.objectId);
    }
  }, [CELLInfo, state]);

  const checkFriend = async (user_id, friend_id) => {
    const isFriend = await firebaseSDK.checkFriend(user_id, friend_id);
    setCanAdd(!isFriend);
  };

  const setImage = async (fileName) => {
    const path = await getImagePath(fileName, MEDIA_FOLDER.USER);
    if (path) {
      setImage_url(path);
    }
  };
  
  return (
    <TouchableOpacity
      style={personComponentStyle.container}
      onPress={onNavigate}
    >
      {
        image_uri ?
          (
            <Image
              style={personComponentStyle.headerImage}
              source={{uri: image_uri} }
            />
          ) : 
          (
            <Image
              style={personComponentStyle.headerImage}
              source={images.ic_default_profile}
            />
          )
      }
      <View
        style={{
          flex: 1,
          flexDirection: 'row',
          justifyContent: 'space-between',
          alignItems: 'center',
        }}
      >
        {CELLInfo && (
          <Text variant="label" style={{ color: colors.text.black }}>
            {name}
          </Text>
        )}
        <TouchableOpacity>
          {CELLInfo.type == 'request' && (
            <Ionicons
              name="md-add-circle-outline"
              size={25}
              style={personComponentStyle.addFriend}
              onPress={toggleShow}
            />
          )}
          {CELLInfo.type == 'recommand' && (
            <Image
              style={personComponentStyle.addImage}
              source={images.ic_add_friend}
              onPress={visible}
            />
          )}
          {CELLInfo.type == 'search' && (
            canAdd && (
              <TouchableOpacity onPress={visible}>
                <Image
                  style={personComponentStyle.addImage}
                  source={images.ic_add_friend}
                />
              </TouchableOpacity>
            )
          )}
        </TouchableOpacity>
      </View>
    </TouchableOpacity>
  );
};
