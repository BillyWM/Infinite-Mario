package com.mojang.mario {

import java.io.*;


public class Recorder
{
    private ByteArrayOutputStream baos = new ByteArrayOutputStream();
    private DataOutputStream dos = new DataOutputStream(baos);

    private byte lastTick = 0;
    private int tickCount = 0;

    public void addLong(long val)
    {
            dos.writeLong(val);
    }

    public void addTick(byte tick)
    {
            if (tick == lastTick)
            {
                tickCount++;
            }
            else
            {
                dos.writeInt(tickCount);
                dos.write(tick);
                lastTick = tick;
                tickCount = 1;
            }
    }

    public byte[] getBytes()
    {
        dos.writeInt(tickCount);
        dos.write(-1);
        dos.close();
        return baos.toByteArray();
    }
}
}
