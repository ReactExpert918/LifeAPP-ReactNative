/* eslint-disable react/prop-types */
import React, { useState, useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { View, Text, Image,  TouchableOpacity  } from 'react-native';
import { images } from '../../../assets/pngs';
import Ionicons from 'react-native-vector-icons/Ionicons';
import { expandStyle } from './friendComponentStyle';
import { CHAT_STATE } from '../../../constants/redux';
import { MEDIA_FOLDER } from '../../../services/firebase/storage';
import { getImagePath } from '../../../utils/media';
import { firebaseSDK } from '../../../services/firebase';
import { getmd5 } from '../../../utils/cryptor';

export const QRcodeExpand = ({ visible, data }) => {
  const dispatch = useDispatch();
  const [image_uri, setImage_url] = useState(null);
  const { user } = useSelector((state) => state.Auth);
  const [isVisible, setVisible] = useState(false);
  const [available, setAvailable] = useState(false);
  const startChat = async() => {
    await dispatch({
      type: CHAT_STATE.FRIEND_CHAT,
      payload: { object: data },
    });
    visible(true, data);
  };

  const addFriend = async() => {
    const doc_id = getmd5(`${user.id}-${data.objectId}`);
    await firebaseSDK.creatFriend(user.id, data.objectId, doc_id);
    await firebaseSDK.createSingle(user.id, data.objectId);
    setVisible(true);
  };

  useEffect(() => {
    setImage(`${data.objectId}.jpg`);
  });

  useEffect(() => {
    async function check() {
      let available = await firebaseSDK.checkFriend(user.id, data.objectId);
      setAvailable(available);
    }
    check();
  }, []);

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
        {
          isVisible && (
            <Ionicons style={expandStyle.checkIcon} name="checkmark-circle-sharp" size={25} />
          )
        }
        <Text style={expandStyle.modalText}>
          {data.username}
        </Text>
        <Text style={expandStyle.modalText1}>
          {data.phone}
        </Text>
        {
          isVisible ? (
            <Text style={expandStyle.textContent}>
              Successfully added to your friend list
            </Text>
          ) : (
            <Text style={expandStyle.textContent}>
              Add to friend list to start connection
            </Text>
          )
        }
        {
          isVisible ? (
            <TouchableOpacity 
              style={expandStyle.button}
              onPress={startChat}
            >
              <Text style={expandStyle.buttonText}>Start Chat</Text>
            </TouchableOpacity>
          ) : (
            !available ? (
              <TouchableOpacity 
                style={expandStyle.button}
                onPress={addFriend}
              >
                <Text style={expandStyle.buttonText}>Add Friend</Text>
              </TouchableOpacity>
            ) : (
              <View
                style={expandStyle.button}
              >
                <Text style={expandStyle.buttonText}>Already Add</Text>
              </View>
            )
          )
        }
      </View>
    </>
  );
};