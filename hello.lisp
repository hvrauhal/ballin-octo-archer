;;; Quickload
(ql:quickload "cl-json")
(ql:quickload "drakma")

;;; Settings
(defparameter *username* "cliffwarden")
(setq drakma:*header-stream* nil)
(setq drakma:*text-content-types* (cons '("application" . "json")
                                        drakma:*text-content-types*))

;;; Utility
(defun reddit-about-url (username)
  (format nil "http://www.reddit.com/user/~A/about.json" username))

;;; Functions
(defun get-about (username)
  (json:decode-json-from-string (drakma:http-request (reddit-about-url username))))

(defun get-link-karma (about)
  (cdr (fifth (cdadr about))))

(defun get-comment-karma (about)
  (cdr (sixth (cdadr about))))

(defun get-stats (u)
  (let
      ((about (get-about u)))
  (format t "~A: ~A/~A~%" u (get-link-karma about) (get-comment-karma about))))

(get-stats "cliffwarden")

(ql:quickload :usocket)
(ql:quickload :flexi-streams)
(ql:quickload :cl-store)

(defpackage :usocket-test
  (:use :cl :usocket :cl-store)
  (:export :http-test :tcp-server :tcp-client :udp-server :udp-client))
(in-package :cl-user)
(use-package :usocket-test)
(in-package :usocket-test)

;; UDP
(defun udp-server ()
  (let* ((socket (socket-connect nil nil :protocol :datagram
                                 :local-host "127.0.0.1" :local-port 8888))
         (buffer (make-array 65536 :element-type '(unsigned-byte 8))))
    (multiple-value-bind (buffer size host port)
        (socket-receive socket buffer 65536)
      (flexi-streams:with-input-from-sequence (stream buffer :end size)
        (format t "Server received ~a~%" (restore stream))))))

(defun udp-client ()
  (let* ((socket (socket-connect "127.0.0.1" 8888 :protocol :datagram))
         (buffer (flexi-streams:with-output-to-sequence (stream)
                   (store '(1 2 3 4 5) stream)))
         (length (array-dimension buffer 0)))
    (format t "Client sent ~a~%" '(1 2 3 4 5))

    (socket-send socket buffer length)))

(udp-client)

(defvar *current-server* (udp-server))


(socket-close '*current-server*)
