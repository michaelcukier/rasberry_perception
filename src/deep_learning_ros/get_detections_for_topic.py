#!/usr/bin/env python
from __future__ import absolute_import, division, print_function

import message_filters
import ros_numpy
import rospy
import cv2
from rasberry_perception.msg import ImageDetections
from sensor_msgs.msg import Image, CameraInfo

from deep_learning_ros.compatibility_layer.detection_server import DetectorResultsClient, DETECTOR_OK
from rasberry_perception_pkg.utility import function_timer
from rasberry_perception_pkg.visualisation import draw_detection_msg_on_image


class DeepLearningRosInference:
    def __init__(self, colour_ns, depth_ns, score_thresh=0.5):
        self.colour_topic = colour_ns + "/image_raw"
        self.colour_info_topic = colour_ns + "/camera_info"
        self.depth_topic = depth_ns + "/image_raw"
        self.depth_info_topic = depth_ns + "/camera_info"

        self.visualisation_topic = colour_ns + "/detection/image_raw"
        self.detections_topic = colour_ns + "/detection/predictions"
        self.score_thresh = score_thresh

        # Wait for connection to detection service
        self.detector = DetectorResultsClient()

        # Initialise publisher
        self.detection_vis_pub = rospy.Publisher(self.visualisation_topic, Image)
        self.detections_pub = rospy.Publisher(self.detections_topic, ImageDetections)

        # Initialise subscribers
        self.colour_sub = message_filters.Subscriber(self.colour_topic, Image)
        self.depth_sub = message_filters.Subscriber(self.depth_topic, Image)
        self.depth_info_sub = message_filters.Subscriber(self.depth_info_topic, CameraInfo)
        self.ts = message_filters.ApproximateTimeSynchronizer(
            [self.colour_sub, self.depth_sub, self.depth_info_sub], 10, 0.5)

        self.ts.registerCallback(self.run_detector)

    @function_timer.interval_logger(interval=10)
    def run_detector(self, colour_msg, depth_msg, depth_info_msg):
        result = self.detector(image=colour_msg, score_thresh=self.score_thresh)
        if result.status != DETECTOR_OK:
            return

        # TODO: Add masks
        rgb_image = ros_numpy.numpify(colour_msg)
        depth_image = ros_numpy.numpify(depth_msg)
        vis_canvas = rgb_image

        vis_canvas = draw_detection_msg_on_image(vis_canvas, result.detections, encoding=colour_msg.encoding)

        detection_visualisation_msg = ros_numpy.msgify(Image, vis_canvas, encoding=colour_msg.encoding)
        detection_visualisation_msg.header = colour_msg.header
        self.detection_vis_pub.publish(detection_visualisation_msg)
        self.detections_pub.publish(result.detections)


def _get_detections_for_topic():
    rospy.init_node('deep_learning_detector', anonymous=True)

    # get private namespace parameters
    p_image_ns = rospy.get_param('~image_ns', "/pico_zense/colour")
    p_depth_ns = rospy.get_param('~depth_ns', "/pico_zense/aligned_depth_to_colour")
    p_score = rospy.get_param('~score', 0.5)

    rospy.loginfo("Camera Topic to Detection ROS: ")

    detector = DeepLearningRosInference(colour_ns=p_image_ns, depth_ns=p_depth_ns, score_thresh=p_score)
    rospy.spin()


if __name__ == '__main__':
    _get_detections_for_topic()