/* eslint-disable react/prop-types */
import React, { useState, useEffect } from 'react';
import { useDispatch } from 'react-redux';
import { View, Text, Image,  TouchableOpacity  } from 'react-native';
import { images } from '../../../assets/pngs';
import Ionicons from 'react-native-vector-icons/Ionicons';
import { expandStyle } from './friendComponentStyle';
import { CHAT_STATE } from '../../../constants/redux';
import { MEDIA_FOLDER } from '../../../services/firebase/storage';
import { getImagePath } from '../../../utils/media';

export const ChatExpand = ({ visible, data }) => {
  const dispatch = useDispatch();
  const [image_uri, setImage_url] = useState(null);

  const startChat = async() => {
    await dispatch({
      type: CHAT_STATE.FRIEND_CHAT,
      payload: { object: data[0] },
    });
    visible(true, data[0]);
  };
  useEffect(() => {
    setImage(`${data[0].objectId}.jpg`);
  });

  const setImage = async (fileName) => {
    const path = await getImagePath(fileName, MEDIA_FOLDER.USER);
    if (path) {
      setImage_url(path);
    }
  };

  return(
    <>
      <View style={expandStyle.container}></View>
      <View style={expandStyle.expand}>
        <Ionicons 
          style={expandStyle.close} 
          name="md-close-sharp" 
          size={25}
          onPress={() => visible(false, '')}
        />
        {
          image_uri ?
            (
              <Image
                style={expandStyle.modalImage}
                source={{uri: image_uri} }
              />
            ) : 
            (
              <Image
                style={expandStyle.modalImage}
                source={images.ic_default_profile}
              />
            )
        }
        <Ionicons style={expandStyle.checkIcon} name="checkmark-circle-sharp" size={25} />
        <Text style={expandStyle.modalText}>
          {data[0].username}
        </Text>
        <Text style={expandStyle.modalText1}>
          {data[0].phone}
        </Text>
        <Text style={expandStyle.textContent}>
          Successfully added to your friend list
        </Text>
        <TouchableOpacity 
          style={expandStyle.button}
          onPress={startChat}
        >
          <Text style={expandStyle.buttonText}>Start Chat</Text>
        </TouchableOpacity>
      </View>
    </>
  );
};