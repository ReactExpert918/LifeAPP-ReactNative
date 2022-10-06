import { React, useState } from "react"
import { PersonComponent } from "./component/personComponent"

export const ChatSection = ({items, onNavigate}) => {
    const [showContent, setShowContent] = useState(true);

    return (
        <>
        {
        items.map((data, index) => {
            return (
                <PersonComponent
                    CELLInfo={data}
                    key={`data-${index}`}
                    onNavigate={onNavigate}
                />
            );
        })}
        </>
    );
}