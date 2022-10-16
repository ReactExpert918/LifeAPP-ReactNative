import { CHAT_STATE } from '../../constants/redux';
 
const initialState = {};

const Reducer = (state = initialState, action) => {
  switch (action.type) {
  case CHAT_STATE.FRIEND_CHAT:
  {
    return {...state, payload: action.payload};
  }    
          
  default: {
    return state;
  }
  }
};

export default Reducer;