from locust import HttpUser, task, between
import os


class OpenProject(HttpUser):

    host = 'https://mediacms.projeto12.com.br'
        
    @task(2)
    def view_video(self):
        
        end_point = "/view?m=FmmEZLX48"
        self.client.get(f"{end_point}")
        
    @task(3)
    def list_admin_media(self):
        
        end_point = "/user/admin"
        self.client.get(f"{end_point}")

    @task(1)
    def home(self):
        
        end_point = "/"
        self.client.get(f"{end_point}")