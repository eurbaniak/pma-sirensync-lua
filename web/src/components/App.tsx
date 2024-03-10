import React, { useCallback, useState } from "react";
import { useNuiEvent } from "../hooks/useNuiEvent";
import { clsx } from "clsx";

const initialEnabledState = {
  code1: true,
  code2: false,
  code3: false,
  wail: false,
  yelp: false,
  hilo: false,
  horn: false,
  manual: false,
  aux: false,
};

interface EnabledState {
  [key: string]: boolean;
}

interface EventData {
  element: string;
  enabled: boolean;
}
interface Props {
  enabled: boolean;
  classes?: string;
  children: React.ReactNode;
}

const ItemDiv = ({ enabled, classes, children }: Props) => (
  <div
    className={clsx(`p-4 text-center rounded-md ${classes}`, {
      "bg-gray-900/50": !enabled,
      "bg-teal-600/70": enabled,
    })}
    style={{
      backgroundImage: enabled
        ? "radial-gradient(ellipse at center, lightgray 0%, teal 100%)"
        : undefined,
    }}
  >
    {children}
  </div>
);

const App: React.FC = () => {
  const [enabled, setEnabled] = useState<EnabledState>(initialEnabledState);

  const updateEnabledState = useCallback((...dataList: EventData[]) => {
    setEnabled((prevEnabled) => {
      const updatedEnabled = { ...prevEnabled };
      dataList.forEach((data) => {
        updatedEnabled[data.element] = data.enabled;
      });
      return updatedEnabled;
    });
  }, []);

  useNuiEvent<EventData>("updateEnabledState", updateEnabledState);

  return (
    <div className="control-wrapper">
      <div className="grid grid-cols-9 grid-rows-3 gap-1 text-white font-bold">
        <ItemDiv enabled={enabled.code1} classes="col-span-3">
          CODE 1
        </ItemDiv>
        <ItemDiv enabled={enabled.code2} classes="col-span-3">
          CODE 2
        </ItemDiv>
        <ItemDiv enabled={enabled.code3} classes="col-span-3">
          CODE 3
        </ItemDiv>
        <ItemDiv enabled={enabled.wail} classes="col-span-2">
          WAIL
        </ItemDiv>
        <ItemDiv enabled={enabled.yelp} classes="col-span-2">
          YELP
        </ItemDiv>
        <ItemDiv enabled={enabled.hilo} classes="col-span-2">
          HI-LO
        </ItemDiv>
        <ItemDiv enabled={enabled.horn} classes="col-span-3">
          HORN
        </ItemDiv>
        <ItemDiv enabled={enabled.manual} classes="col-span-3">
          MANUAL
        </ItemDiv>
        <ItemDiv
          enabled={enabled.aux}
          classes="col-span-3 col-start-7 row-start-2 rounded-md row-span-2 pt-9 leading-10"
        >
          AUX
        </ItemDiv>
      </div>
    </div>
  );
};

export default App;
