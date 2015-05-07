(ql:quickload '(usocket cl-json babel))

(defparameter *should-break* nil)

(defun real-udp-handler (buffer)
  (declare (type (simple-array (unsigned-byte 8) *) buffer))
  (format t "S: Got a packet: ~A~%S: From ~A:~A~%" (json-octets-to-alist buffer) usocket:*remote-host* usocket:*remote-port*)
  (if *should-break* (error "Done..."))
  (alist-to-json-octets '((type . pong) (connection-id . "abcdef"))))

(defun udp-handler-handle (buffer) 
  (real-udp-handler buffer))

(defun alist-to-json-octets (an-alist)
  (babel:string-to-octets (json:encode-json-alist-to-string an-alist) :encoding :utf-8))

(defun json-octets-to-alist (octets) 
  (let ((a-the-json-string (babel:octets-to-string octets :encoding :utf-8)))
    (json:decode-json-from-string a-the-json-string)))

(let* ((sample-original-alist '((type . pong) (connection-id . "abcdefg")))
       (sample-octets (alist-to-json-octets sample-original-alist))
       (sample-as-alist (json-octets-to-alist sample-octets)))
  (cdr (assoc :type sample-as-alist)))

(defun start-server () 
  (sb-thread:make-thread 
   #'(lambda (standard-output)
       (let ((*standard-output* standard-output)
             (port 12321))
         (format t "S: Starting the server at port ~A~%" port)
         (usocket:socket-server usocket:*wildcard-host* port #'udp-handler-handle nil :protocol :datagram)
         (format t "S: Server done.")))
   :arguments (list *standard-output*)))
