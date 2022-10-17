/* eslint-disable react/prop-types */
import React ,{ useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { View, Text, Image,  TouchableOpacity } from 'react-native';
import Modal from 'react-native-modal';
import { getImagePath } from '../../../utils/media';
import { colors } from '../../../assets/colors';
import { images } from '../../../assets/pngs';
import { MEDIA_FOLDER } from '../../../services/firebase/storage';
import { friendStyle } from '../style';
import { FRIEND_STATE } from '../../../constants/redux';
import { firebaseSDK } from '../../../services/firebase';

export const ChatModal = ({ data, show }) => {
  const { user } = useSelector((state) => state.Auth);
  const dispatch = useDispatch();
  const handleModal = () => {
    dispatch({
      type: FRIEND_STATE.REQUEST,
      show: false,
      data: {}
    });
  };

  const acceptFriend = async () => {
    await firebaseSDK.acceptFriend(data.objectId, user.id);
    handleModal();
  };

  const declineFriend = async() => {
    await firebaseSDK.declineFriend(data.objectId, user.id);
    handleModal();
  };

  const [image_uri, setImage_url] = useState(null);
  useEffect(() => {
    if (data && data != {}) {
      setImage(`${data.objectId}.jpg`);
    }
  }, [data]);

  const setImage = async (fileName) => {
    const path = await getImagePath(fileName, MEDIA_FOLDER.USER);
    if (path) {
      setImage_url(path);
    }
  };

  return(
    <Modal 
      isVisible={show} 
      style={friendStyle.modal}
    >
      <View style={friendStyle.modalContainer}>
        {
          image_uri ? 
            <Image 
              style={friendStyle.modalImage} 
              source={{uri: image_uri}}
            /> : 
            <Image 
              style={friendStyle.modalImage} 
              source={images.ic_default_profile}
            />
        }
        <Text style={friendStyle.modalText}>
          Do you want to add &nbsp;
          <Text style={{fontWeight: 'bold', color: colors.text.primary}}>
            {data && data.username}
          </Text>
          &nbsp; your friend list ?
        </Text>
        <View style={friendStyle.buttonContainer}>
          <TouchableOpacity 
            style={friendStyle.declineButton}
            onPress={declineFriend}
          >
            <Text style={{color: 'black'}}>Decline</Text>
          </TouchableOpacity>
          <TouchableOpacity 
            style={friendStyle.acceptButton}
            onPress={acceptFriend}
          >
            <Text style={{color: 'white'}}>Accept</Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );
};