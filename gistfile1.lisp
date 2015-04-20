
;;; Quickload
(ql:quickload '(cl-json drakma))

;;; Settings
(defparameter *username* "cliffwarden")
(setf drakma:*header-stream* nil)
(push '("application" . "json") drakma:*text-content-types*)

;;; Utility
(defun reddit-about-url (username)
  (format nil "http://www.reddit.com/user/~A/about.json" username))

;;; Functions
(defun get-about (username)
  (json:decode-json-from-string (drakma:http-request (reddit-about-url username))))

(defun get-link-karma (about)
  (cdr (assoc :link--karma (cdr (assoc :data about)))))

(defun get-comment-karma (about)
  (cdr (assoc :comment--karma (cdr (assoc :data about)))))

(defun get-stats (u)
  (let
      ((about (get-about u)))
  (format t "~A: ~A/~A~%" u (get-link-karma about) (get-comment-karma about))))
