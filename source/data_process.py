import tensorflow as tf
import numpy as np
import os
import one_hot_encoder


# 定义函数转化变量类型。
def _int64_feature(value):
    return tf.train.Feature(int64_list=tf.train.Int64List(value=[value]))


def _bytes_feature(value):
    return tf.train.Feature(bytes_list=tf.train.BytesList(value=[value]))

# 输出TFRecord的文件地址
filename = "/home/mxqian/Projects/Captcha/captcha_data/Records/captcha_data_train.tfrecords"
# 创建一个writer来写TFRecord
writer = tf.python_io.TFRecordWriter(filename)
# 顺序读取文件夹下的图片
fold = os.listdir("/home/mxqian/Projects/Captcha/captcha_data/data_train")
for i in fold:
    # print(i)
    fold1 = os.listdir("/home/mxqian/Projects/Captcha/captcha_data/data_train/"+i)
    # 使用tensorflow读入图片，并转换为tfrecord格式
    with tf.Session() as sess:
        for file in fold1:
            # 读取图像
            image_raw_data = tf.gfile.FastGFile("/home/mxqian/Projects/Captcha/captcha_data/data_train/" + i + "/"
                                                + file, 'r').read()
            img_data = tf.image.decode_jpeg(image_raw_data)
            # print(img_data.eval())

            # 转换为字符串
            img_data = img_data.eval().tostring()
            # print(len(img_data))
            label = ord(i[0])
            print(label)
            # 文件中包含两种数据类型，一种为样本的数据，一种为样本的类标
            example = tf.train.Example(features=tf.train.Features(feature={
                'data': _bytes_feature(img_data),
                'label': _int64_feature(label)
                }))
            # 将一个example写入TFRecord文件
            writer.write(example.SerializeToString())

writer.close()

# 输出TFRecord的文件地址
filename_test = "/home/mxqian/Projects/Captcha/captcha_data/Records/captcha_data_test.tfrecords"
# 创建一个writer来写TFRecord
writer1 = tf.python_io.TFRecordWriter(filename_test)
# 顺序读取文件夹下的图片
fold = os.listdir("/home/mxqian/Projects/Captcha/captcha_data/data_test")
for i in fold:
    # print(i)
    fold1 = os.listdir("/home/mxqian/Projects/Captcha/captcha_data/data_test/"+i)
    # 使用tensorflow读入图片，并转换为tfrecord格式
    with tf.Session() as sess:
        for file in fold1:
            # 读取图像
            image_raw_data = tf.gfile.FastGFile("/home/mxqian/Projects/Captcha/captcha_data/data_test/" + i + "/"
                                                + file, 'r').read()
            img_data = tf.image.decode_jpeg(image_raw_data)

            # 转换为字符串
            img_data = img_data.eval().tostring()
            label = ord(i)
            # 文件中包含两种数据类型，一种为样本的数据，一种为样本的类标
            example = tf.train.Example(features=tf.train.Features(feature={
                'data': _bytes_feature(img_data),
                'label': _int64_feature(label)
                }))
            # 将一个example写入TFRecord文件
            writer1.write(example.SerializeToString())

writer1.close()
