from sklearn import svm
import tensorflow as tf
import numpy as np
import extract_data
import one_hot_encoder

with tf.Session() as sess:
    coord = tf.train.Coordinator()
    threads = tf.train.start_queue_runners(sess=sess, coord=coord)
    clf = svm.SVC()

    for i in range(10):
        image_train, label_train = sess.run([extract_data.image_batch_train, extract_data.label_batch_train])
        # for l in range(np.shape(label_train)[0]):
        #     print(chr(label_train[l]))
        # label_train = one_hot_encoder.array_fit(label_train)
        # for j in range(np.shape(image_train)[0]):
        #     plt.imshow(np.reshape(image_train[j], [16, 16]))
        #     plt.show()
        # print(np.shape(image_train))
        # print(label_train)

        # 调用svm进行训练
        print("开始训练：")
        clf.set_params(kernel='rbf').fit(image_train, label_train)
        print("训练完成!")

    image_test, label_test = sess.run([extract_data.image_batch_test, extract_data.label_batch_test])
    # 进行测试
    print("开始测试：")
    test_result = clf.predict(image_test)
    print("the accuracy is: %f" % np.mean(np.equal(test_result, label_test)))
    print("测试完成！")

    coord.clear_stop()
    coord.join(threads)